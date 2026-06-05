# range-as-code

A purple team cyber range, built entirely as infrastructure-as-code on a Proxmox homelab. No turnkey tools, no black boxes — just Packer, Terraform, and Ansible doing what they do best.

## What is this?

This repo contains everything needed to stand up a small Active Directory environment for attack-and-defend practice. The idea is simple: build a realistic network, break into it, detect the break-in, and write rules so it gets caught next time.

The whole thing runs on a two-node Proxmox cluster at home. One node hosts the range (red team playground), the other will eventually host the blue team stack (SIEM, network sensors, detection logic). Everything is defined in code so the range can be torn down and rebuilt from scratch in minutes.

## The Range

Four machines, one network:

| VM | Role | OS | IP |
|---|---|---|---|
| DC01 | Domain Controller | Windows Server 2022 | 10.0.20.60 |
| WS01 | Domain Workstation | Windows 11 Enterprise | 10.0.20.61 |
| target01 | Linux Target | Ubuntu Server 22.04 | 10.0.20.62 |
| kali | Attacker | Kali Linux | 10.0.20.63 |

## How it's built

**Templates** — Golden images that VMs are cloned from. The Windows templates are built with [Packer](https://www.packer.io/) (unattended installs, VirtIO drivers, WinRM for automation). The Linux templates use pre-built cloud images with cloud-init.

**Deployment** — [OpenTofu](https://opentofu.org/) (open-source Terraform) with the [bpg/proxmox](https://github.com/bpg/terraform-provider-proxmox) provider clones the templates and configures networking. One `tofu apply` and the range is up.

**Configuration** — Ansible handles the post-deployment setup: AD promotion, domain join, Sysmon, log forwarding. *(work in progress)*

## Repo layout

```
├── packer/
│   ├── windows-server-2022/    # DC template (Packer + Autounattend)
│   └── windows-11-enterprise/  # Workstation template (Packer + Autounattend)
├── terraform/                  # Range VM deployment
│   ├── provider.tf
│   ├── variables.tf
│   └── main.tf
├── scripts/                    # Cloud image template setup (Ubuntu, Kali)
└── ansible/                    # Post-deployment config (coming soon)
```

## What's working

- [x] Windows Server 2022 template (Packer, unattended, sysprep'd)
- [x] Windows 11 Enterprise template (Packer, TPM bypass, sysprep'd)
- [x] Ubuntu Server 22.04 template (cloud image + cloud-init)
- [x] Kali Linux template (cloud image + cloud-init)
- [x] Terraform deploys all four VMs from templates
- [x] Linux VMs get static IPs and SSH access via cloud-init
- [x] Windows VMs have WinRM enabled for Ansible

## What's next

- [ ] Ansible: promote DC01, join WS01 to domain, deploy Sysmon
- [ ] Blue stack on a separate node (SIEM + Suricata/Zeek)
- [ ] Detection-as-code: Sigma rules with CI/CD validation
- [ ] Purple team loop: ATT&CK technique → attack → detect → write rule
- [ ] Network isolation (dedicated range bridge, controlled routing)

## Environment

This runs on a two-node Proxmox VE 9.2 cluster with shared NFS storage (TrueNAS). The range VMs live on the second node so the first stays clean for the blue team stack. A small LXC container on the range node acts as the IaC workstation — Packer, OpenTofu, and Ansible all run from there.

Nothing fancy hardware-wise. Just a couple of mini PCs, a gigabit switch, and a NAS.

## Why not Ludus / GOAD / DetectionLab?

Looked at all of them. Ludus takes over the entire host (can't run anything else on that node). GOAD is solid but it's someone else's lab — deploying it shows you can follow instructions, not that you can build infrastructure. This project is the "I built it myself" version, using the same tools (Packer, Terraform, Ansible) that real environments use.
