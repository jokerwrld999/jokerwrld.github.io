---
layout: post
title: 'Proxmox Essentials: Building a Robust Virtualization Environment'
image:
  path: "/assets/img/2024/thumbs/proxmox-essentials.webp"
categories:
- Self-hosted
- Configuration Management
- Networking
tags:
- Linux
- Bash
- Proxmox
date: 2024-01-14 22:01 +0200
---
[Proxmox Virtual Environment](https://www.proxmox.com/en/){:target="_blank"} (Proxmox VE) is an open-source platform that combines two virtualization technologies: KVM (Kernel-based Virtual Machine) for virtual machines and LXC (Linux Containers) for lightweight container-based virtualization. This powerful solution allows users to manage virtual machines, containers, storage, and networking through a web-based interface.

## Installation

[Check the Get Started Guide on How To Install Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment/get-started){:target="_blank"}

> During the installation, you can configure network settings. If you prefer to use DHCP initially, leave the settings as is. For those who want to set a static IP later, proceed with DHCP for now.
{: .prompt-info}

- **Setting Static IP Post-Installation:**

  You can also separate bridge networking to use custom IP rage for your VMs and LXCs see [post](https://docs.jokerwrld.win/posts/proxmox-and-tailscale/#solution-steps){:target='_blank'}.

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
  {: file="/etc/network/interfaces"}

  Save the file and restart the networking service:

  ```shell
  service networking restart
  ```

## First Setup

### Disable Commercial Repositories

Add No-Subscription repository:

```bash
echo 'deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription' > /etc/apt/sources.list.d/pve-no-subscription.list
```

Disable the enterprise repo:

```bash
sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/pve-enterprise.list
```

Disable the ceph repo:

```bash
sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/ceph.list
```

To install the newest updates run:

```bash
apt update && apt dist-upgrade -y
```

```bash
reboot
```

### Remove Subscription Alert

```bash
sed -i.backup -z "s/res === null || res === undefined || \!res || res\n\t\t\t.data.status.toLowerCase() \!== 'active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service
```

## Cloud-Init Image Template

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

## **Attach Pass Through Disk**

### **Identify Disk**

When attaching pass-through disks in Proxmox, it's crucial to use stable device paths like `/dev/disk/by-id/` instead of generic names like `/dev/sdc`, as the latter can change between reboots. Follow these steps to identify the disk:

```bash
ls -l /dev/disk/by-id/ | grep sda
```

The output should resemble something similar to the following, where you match the serial number with the physical disk:

![Proxmox Essentials Identifying Disk](/assets/img/2024/posts/proxmox-essentials-identifying-disk.webp)

### **Update Configuration**

**Hot-Plug/Add physical device as new virtual SCSI disk**

```bash
qm set 115 -scsi1 /dev/disk/by-id/ata-WDC_WD40EFAX-68JH4N1_WD-WX12D80NJSVS
```

**Hot-Unplug/Remove virtual disk**
```bash
qm unlink 115 --idlist scsi1
```

## Add Additional Hard Drive to Proxmox

To add an additional hard drive to your Proxmox server, follow these steps:

1. **Connect the Hard Drive:**

   - Physically connect the hard drive to your server.

   - Log in to the Proxmox console or connect via SSH from another computer.

2. **Identify the New Disk:**

   - Use the following command to identify the new disk:

     ```bash
     lsblk
     ```

   - Look for the disk names like `sda` and `sdb`. Work with the drive that has a higher size.

3. **Format the Drive:**

   - Ensure you have the `parted` tool installed. If not, install it using:

     ```bash
     apt policy parted
     apt install parted
     ```
   - Create a new partition table of type GPT:

     ```bash
     parted /dev/sda mklabel gpt
     ```
     Confirm the action when prompted.

   - Create a new primary partition with Ext4 filesystem using 100% of the disk:

     ```bash
     parted -a opt /dev/sda mkpart primary ext4 0% 100%
     ```

   - Check the new layout with:
     ```bash
     lsblk
     ```

4. **Create Ext4 Filesystem:**

   - Create an Ext4 filesystem on the newly created partition (sda1 in this case):

     ```bash
     mkfs.ext4 -L hdd_storage /dev/sda1
     ```

5. **Mount the New Disk:**

   - Create a new directory to mount the partition:

     ```bash
     mkdir -p /mnt/hdd_storage
     ```
   - Modify `/etc/fstab` to automatically mount the partition upon system boots:

     ```bash
     nano /etc/fstab
     ```
     Add the following line:

     ```bash
     LABEL=hdd_storage /mnt/hdd_storage ext4 defaults 0 2
     ```
   - Mount the drive:

     ```bash
     mount -a
     ```
   - Confirm the mount by checking with:

     ```bash
     lsblk
     ```
     The /dev/sda1 should be mounted as /mnt/hdd_storage.
