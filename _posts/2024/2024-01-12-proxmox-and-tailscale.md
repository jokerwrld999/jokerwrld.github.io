---
layout: post
title: Access Proxmox server from anywhere /W Tailscale
image:
  path: "/assets/img/2024/thumbs/proxmox-and-tailscale.webp"
categories:
- Self-hosted
- Networking
- Guide
tags:
- Linux
- Proxmox
- Ubuntu
- Tailscale
date: 2024-01-12 21:08 +0200
---
## Proxmox Bridge for VMs and Containers Setup

### Overview

In the [Proxmox environment](https://www.proxmox.com/en/proxmox-virtual-environment/overview){:target='_blank'}, bridges act as virtual switches implemented in software, enabling communication among virtual guests. You can either have all virtual guests share a single bridge or create multiple bridges to segregate network domains. However, when hosting providers detect multiple MAC addresses on a single interface, they often disable networking for security reasons.

### Problem with Same Local Network

Most hosting providers disable networking when they detect multiple MAC addresses on a single interface. This restriction poses challenges, especially if you want to set up multiple bridges for virtual guests. To address this, routing all traffic via a single interface is a common workaround. This ensures that all network packets use the same MAC address, avoiding the provider's imposed limitations.

### Solution Steps

1. **Edit `/etc/network/interfaces` File**

   - Open the `/etc/network/interfaces` file and configure the network interfaces, addressing, and routing rules.

   - The configuration involves specifying the static IP address, gateway, and creating a virtual bridge `vmbr0` with associated settings.

   - Masquerading allows guests having only a private IP address to access the network by using the host IP address for outgoing traffic. Each outgoing packet is rewritten by iptables to appear as originating from the host, and responses are rewritten accordingly to be routed to the original sender.

   ```bash
   auto lo
   iface lo inet loopback
   
   iface eno1 inet manual
   
   auto eno1
   iface eno1 inet static
           address 192.168.200.116/24
           gateway 192.168.200.1
   
   auto vmbr0
   iface vmbr0 inet static
           address 10.10.10.254/24
           bridge-ports none
           bridge-stp off
           bridge-fd 0
   
           post-up echo 1 > /proc/sys/net/ipv4/ip_forward
           post-up iptables -t nat -A POSTROUTING -s '10.10.10.0/24' -o eno1 -j MASQUERADE
           post-down iptables -t nat -D POSTROUTING -s '10.10.10.0/24' -o eno1 -j MASQUERADE
   ```
   {: file="/etc/network/interfaces"}

2. **Restart Networking**

   - Apply the changes by restarting the networking service.

   ```bash
   systemctl restart networking
   ```

3. **Create VMs and LXCs**

   - Now, you can create virtual machines (VMs) and Linux containers (LXCs) within this private network (`10.10.10.0/24`).

4. **Setup Tailscale**

   - Utilize Tailscale to access VMs and LXCs from anywhere securely.

## LXC Tailscale Setup

### Overview:

Tailscale provides a secure, point-to-point connection, making it ideal for accessing services within a private network from anywhere. Setting it up within an LXC container ensures encrypted communication and flexibility.

### Problem with Same Local Network:

When utilizing the same local network for multiple services, you may encounter accessibility challenges, like access your homelab services that now are on the bridged network and do not have direct access without static routing, port forwarding or some kind of reverse proxy.

[Tailscale](https://tailscale.com/){:target='_blank'} adeptly resolves this issue by establishing a secure overlay network. This innovative approach enables seamless and secure access to services within the private network without the need for port forwarding or static routes, making it especially advantageous in scenarios where direct access to the router is unavailable.

### Solution Steps:

1. **Create Ubuntu LXC:**

    - Start by creating an Ubuntu LXC container within Proxmox. You can get it from [Proxmox VE Helper-Scripts](https://tteck.github.io/Proxmox/){:target='_blank'}

    - To create a new Proxmox VE Ubuntu LXC, run the command bellow in the `Proxmox VE Shell`.

    ```bash
    bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/ubuntu.sh)"
    ```

2. **Add Tailscale to LXC:**

    - Run a script in the `Proxmox VE Shell` to add Tailscale to the Ubuntu LXC container.

    ```bash
    bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/add-tailscale-lxc.sh)"
    ```

3. **Reboot LXC Container:**

    - After adding Tailscale, reboot the LXC container to apply changes.

    ```bash
    pct reboot <lxc-id>
    ```

4. **Run Tailscale**
    - Initiate Tailscale within the LXC container and advertise routes.

    ```bash
    tailscale up --advertise-routes=192.168.200.0/24,10.10.10.0/24 --accept-routes
    ```

5. **Configure Tailscale**

    - Log in to Tailscale, edit route settings, and check `Subnet routes` for enhanced control.

6. **Connect from Any Device:**

    - Verify access by connecting from any device outside the local network.

These setup procedures provide a solution to the challenges posed by using the same local network for multiple services, ensuring secure and efficient communication within a Proxmox environment.