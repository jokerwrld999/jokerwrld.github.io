---
layout: post
title: HomeLab Containers
image:
  path: "/assets/img/2023/thumbs/default.webp"
categories:
- Self-hosted
- Automation
- CI/CD
- Configuration Management
- Infrastructure as Code (IaC)
- Networking
- Monitoring
- Project
- Guide
tags:
- Git
- Linux
- Bash
- Nginx
- Docker
- Kubernetes
- Ansible
- AWS
- Terraform
- Jenkins
- Python
- Prometheus
- Grafana
---


HomeLab Containers is a project about how to selfhost different services in your environment.



## Proxmox

Commands, Environment, Clusters, Cloud-Init, Template, Base Setup, Tagging, Cloning

[Proxmox Virtual Environment](https://www.proxmox.com/en/){:target="_blank"} (Proxmox VE) is an open-source platform that combines two virtualization technologies: KVM (Kernel-based Virtual Machine) for virtual machines and LXC (Linux Containers) for lightweight container-based virtualization. This powerful solution allows users to manage virtual machines, containers, storage, and networking through a web-based interface.

### Installation

[Check the Get Started Guide on How To Install Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment/get-started){:target="_blank"}

> During the installation, you can configure network settings. If you prefer to use DHCP initially, leave the settings as is. For those who want to set a static IP later, proceed with DHCP for now.
{: .prompt-info}

- **Setting Static IP Post-Installation:**

  After completing the Proxmox installation, you can set a static IP by modifying the network configuration file or in DHCP setting of your router. Connect to the Proxmox host using SSH or directly through the console, and edit the network configuration file:

  ```shell
  nano /etc/network/interfaces
  ```

  Locate the line containing `iface vmbr0` (or your relevant interface) and change it to:

  ```shell
  auto lo
  iface lo inet loopback

  iface eno1 inet manual

  auto vmbr0
  iface vmbr0 inet static
          address 192.168.1.10/24
          gateway 192.168.1.254
          bridge-ports eno1
          bridge-stp off
          bridge-fd 0

  iface enx98e74303cde3 inet manual

  iface wlp0s20f3 inet manual
  ```

  Save the file and restart the networking service:

  ```shell
  service networking restart
  ```

### First Setup

#### Updates

Create a file at `/etc/apt/sources.list.d/pve-no-enterprise.list` with the following contents:

```bash
# not for production use
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
```

Run

```bash
apt-get update
```

```bash
apt dist-upgrade
```

```bash
reboot
```

#### Remove Subscription Alert

```bash
sed -i.backup -z "s/res === null || res === undefined || \!res || res\n\t\t\t.data.status.toLowerCase() \!== 'active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service
```

### Cloud-Init Image Template

Choose your [Ubuntu Cloud Image](https://cloud-images.ubuntu.com/)

- **Download Ubuntu (replace with the url of the one you chose from above)**

  ```bash
  wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
  ```

- **Create a new virtual machine**

  ```bash
  qm create 8000 --memory 4096 --core 4 --name ubuntu-cloud --net0 virtio,bridge=vmbr0
  ```

- **Import the downloaded Ubuntu disk to local-lvm storage**

  ```bash
  qm importdisk 8000 jammy-server-cloudimg-amd64.img local-lvm
  ```

- **Attach the new disk to the vm as a scsi drive on the scsi controller**

  ```bash
  qm set 8000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-8000-disk-0
  ```

- **Add cloud init drive**

  ```bash
  qm set 8000 --ide2 local-lvm:cloudinit
  ```

- **Make the cloud init drive bootable and restrict BIOS to boot from disk only**

  ```bash
  qm set 8000 --boot c --bootdisk scsi0
  ```

- **Add serial console**

  ```bash
  qm set 8000 --serial0 socket --vga serial0
  ```

- **DO NOT START YOUR VM**

  Now, configure hardware and cloud init, then create a template and clone. If you want to expand your hard drive you can on this base image before creating a template or after you clone a new machine. I prefer to expand the hard drive after I clone a new machine based on need.

- **Create template**

  ```bash
  qm template 8000
  ```

- **Clone template**

  ```bash
  qm clone 8000 101 --name homelab --full
  ```

> To use cloud-init, click on the new VM you made, go to `Cloud-Init` tab and customize your settings and click on `Regenerate Image` and that’s it! Start your new cloned VM and after waiting for the boot sequence to finish you should get directly to a login prompt. Enjoy!
{: .prompt-tip}

- **Resize Proxmox VM**

  ```bash
  qm shutdown 101
  qm set 101 --memory 8192 --core 4
  qm resize 101 scsi0 +80G
  ```

## Docker && Docker Compose

Volumes, networks...

## Nginx Proxy Manager

## Dashy

## Portainer

## Jenkins

## Cloudflare Tunnel

## TrueNAS Scale

## MediaFile hosting Next Cloud

## Gaming server
