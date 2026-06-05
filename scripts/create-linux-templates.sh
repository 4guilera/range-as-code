#!/bin/bash
# create-linux-templates.sh
# Creates Ubuntu Server and Kali Linux templates from cloud images.
# Run this from a Proxmox node (e.g., pve-node2).
#
# These don't need Packer — cloud images come pre-built with cloud-init
# support, so we just download, import, and convert to template.

set -e

STORAGE="local-lvm"
ISO_STORAGE="TrueNAS"

# --- Ubuntu Server 22.04 LTS (VMID 9002) ---
echo "==> Downloading Ubuntu 22.04 cloud image..."
wget -q --show-progress -O /tmp/ubuntu-cloud.img \
  https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

echo "==> Creating Ubuntu template (9002)..."
qm create 9002 --name ubuntu-server-template --memory 2048 --cores 2 \
  --cpu host --net0 virtio,bridge=vmbr0 --ostype l26 --agent enabled=1

qm importdisk 9002 /tmp/ubuntu-cloud.img $STORAGE
qm set 9002 --scsihw virtio-scsi-single --scsi0 $STORAGE:vm-9002-disk-0
qm set 9002 --ide2 $STORAGE:cloudinit
qm set 9002 --boot order=scsi0
qm set 9002 --serial0 socket --vga serial0
qm resize 9002 scsi0 +28G
qm template 9002

echo "==> Ubuntu template done (9002)"

# --- Kali Linux (VMID 9003) ---
echo "==> Downloading Kali cloud image..."
wget -q --show-progress -O /tmp/kali-cloud.tar.xz \
  https://kali.download/cloud-images/current/kali-linux-2026.1-cloud-genericcloud-amd64.tar.xz

mkdir -p /tmp/kali
tar -xJf /tmp/kali-cloud.tar.xz -C /tmp/kali

echo "==> Creating Kali template (9003)..."
qm create 9003 --name kali-template --memory 4096 --cores 2 \
  --cpu host --net0 virtio,bridge=vmbr0 --ostype l26 --agent enabled=1

qm importdisk 9003 /tmp/kali/disk.raw $STORAGE
qm set 9003 --scsihw virtio-scsi-single --scsi0 $STORAGE:vm-9003-disk-0
qm set 9003 --ide2 $STORAGE:cloudinit
qm set 9003 --boot order=scsi0
qm set 9003 --serial0 socket --vga serial0
qm resize 9003 scsi0 +56G
qm template 9003

echo "==> Kali template done (9003)"

# Cleanup
rm -f /tmp/ubuntu-cloud.img /tmp/kali-cloud.tar.xz
rm -rf /tmp/kali

echo "==> All Linux templates ready!"
