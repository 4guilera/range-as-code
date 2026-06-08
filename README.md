# range-as-code

A purple team cyber range built as infrastructure-as-code on a Proxmox homelab. I built this using Packer, Terraform, and Ansible.

## What is this?

This is how I set up a small Active Directory environment for attack-and-defend practice. The idea was simple: build a realistic network, break into it, detect the break-in, and write rules so it gets caught next time.

The whole thing runs on my two-node Proxmox cluster. One node hosts the red team playground while the other hosts the blue team stack (SIEM, network sensors, detection logic). Everything is defined in code so the range can be torn down and rebuilt from scratch in minutes.

## The Range

Four machines, one network:

| VM | Role | OS | IP |
|---|---|---|---|
| DC01 | Domain Controller | Windows Server 2022 | 10.0.20.60 |
| WS01 | Domain Workstation | Windows 11 Enterprise | 10.0.20.61 |
| target01 | Linux Target | Ubuntu Server 22.04 | 10.0.20.62 |
| kali | Attacker | Kali Linux | 10.0.20.63 |

## How it's built

**Templates** — The Windows templates are built with [Packer](https://www.packer.io/) (unattended installs, VirtIO drivers, WinRM for automation). The Linux templates use pre-built cloud images with cloud-init.

**Deployment** — [OpenTofu](https://opentofu.org/) (open-source Terraform) with the [bpg/proxmox](https://github.com/bpg/terraform-provider-proxmox) provider clones the templates and configures networking. One `tofu apply` and the range is up.

**Configuration** — Ansible handles the post-deployment setup: 
- Active Directory: Forest creation, domain join
- Endpoint Monitoring: Sysmon on all Windows hosts
- SIEM: Splunk on node1 with universal forwarders shipping sysmon, security, system, and application logs from DC01 and WS01

## Repo layout

```
├── packer/
│   ├── windows-server-2022/    # DC template (Packer + Autounattend)
│   └── windows-11-enterprise/  # Workstation template (Packer + Autounattend)
├── terraform/                  # Range VM deployment
│   ├── provider.tf
│   ├── variables.tf
│   └── main.tf
├── ansible/
│   ├── inventory/hosts.yml     # All hosts (Windows + Linux + Blue)
│   └── playbooks/
│       ├── 01-promote-dc.yml        # AD forest creation
│       ├── 02-domain-join.yml       # Join WS01 to range.lab
│       ├── 03-deploy-sysmon.yml     # Sysmon on Windows hosts
│       ├── 04-install-splunk.yml    # Splunk Enterprise on node1
│       └── 05-deploy-forwarder.yml  # Universal Forwarder on Windows
├── scripts/
│   └── create-linux-templates.sh    # Ubuntu + Kali cloud image setup
└── README.md
```

## What's working

- [x] Windows Server 2022 template (Packer, unattended, sysprep'd)
- [x] Windows 11 Enterprise template (Packer, TPM bypass, sysprep'd)
- [x] Ubuntu Server 22.04 template (cloud image + cloud-init)
- [x] Kali Linux template (cloud image + cloud-init)
- [x] Terraform deploys all four VMs from templates
- [x] Linux VMs get static IPs and SSH access via cloud-init
- [x] Windows VMs have WinRM enabled for Ansible
- [x] DC01 promoted to domain controller
- [x] WS01 joined to domain
- [x] Sysmon deployed on DC01 and WS01
- [x] Splunk Enterprise running on node1
- [x] Universal Forwarder shipping logs from both Windows hosts to Splunk
- [x] Sysmon, Security, System, and Application event logs indexed in Splunk
- [x] Detection-as-code: Sigma rules with CI/CD validation

## What's next

- [ ] Suricata network sensor on the Splunk VM
- [ ] Purple team loop: ATT&CK technique → attack → detect in Splunk → write rule

## Environment

This runs on a two-node Proxmox VE 9.2 cluster with shared NFS storage (TrueNAS). The range VMs live on the second node so the first stays clean for the blue team stack. A small LXC container on the range node acts as the IaC workstation — Packer, OpenTofu, and Ansible all run from there.



