---
layout: post
title: Traditional VPN & Overlay Networks
image:
  path: "/assets/img/2024/thumbs/traditional-vpn-overlay-networks.webp"
categories:
- Self-hosted
- Networking
tags:
- Linux
date: 2024-01-12 19:29 +0200
---
In an era dominated by digital connectivity, the term VPN, or Virtual Private Network, has become a buzzword often associated with online privacy and security. Let's embark on a journey to demystify what a VPN is and explore its diverse use cases that extend far beyond just anonymity.

### **What is a VPN?**

At its core, a Virtual Private Network (VPN) is a technology that establishes a secure and encrypted connection over the internet, creating a private network even when utilizing public networks. This encrypted tunnel shields your online activities from prying eyes, ensuring a heightened level of privacy and security.

### **Use Cases of VPNs**

1. **Protection on Public Networks:**

   - **Scenario:** Using public Wi-Fi at airports, hotels or cafes.

   - **VPN Solution:** Safeguard your data from potential hackers on unsecured networks by encrypting your connection with a VPN.

2. **Bypassing Geo-restrictions**

   - **Scenario:** You want to access region-restricted content on streaming platforms.

   - **VPN Solution:** By connecting to a server in the desired region, a VPN can make it appear as if you're browsing from that location, unlocking geo-restricted content.

3. **Enhanced Online Privacy**

   - **Scenario:** Concerns about online tracking and monitoring.

   - **VPN Solution:** A VPN masks your IP address, making it challenging for websites and online services to trace your online activities, thus preserving your digital privacy.

4. **Remote Access to Corporate Networks**

   - **Scenario:** Working remotely and needing secure access to company resources.

   - **VPN Solution:** Employees can connect to the company's VPN, ensuring a secure channel for accessing sensitive corporate data from anywhere in the world.

5. **Anonymous Browsing:**

   - **Scenario:** You want to browse the internet without leaving a trace.

   - **VPN Solution:** By routing your traffic through a VPN server, your true IP address remains hidden, offering a layer of anonymity during your online adventures.

## Traditional VPNs vs. Overlay Networks: Navigating the Landscape

### Traditional VPNs

![Traditional VPN Systems](/assets/img/2024/posts/traditional-vpn-architecture.webp)

In this configuration, the aim is to establish a secure connection from an untrusted network to your home office network. The VPN resides on your firewall, boasting a public IP address accessible from other networks. Popular protocols for this setup include OpenVPN, IPsec, and WireGuard, which are all good protocols.

#### **Protocol Choices**

- **OpenVPN and WireGuard:** These are often preferred due to their compatibility with Network Address Translation (NAT) and robust security features.

### **Accessing the Network**

Normal access, especially for home users, involves connecting to the firewall, granting access to all resources on the network. However, for more advanced setups, employing protocols like RADIUS with pfSense can lead to granular control. With a RADIUS server, specific resources can be assigned, and firewall rules can be fine-tuned to regulate user permissions.

#### **Advanced Access Control**

- **RADIUS Integration:** Enhances access control by allowing the definition of specific resources for each user.

- **Granular Firewall Rules:** Tailor access permissions based on predefined rules, limiting or expanding user privileges.

#### **Simplicity in Action**

This VPN setup doesn't necessitate third-party utilities loaded on servers within the network. Once within the perimeter network, resources such as NAS, printers, desktops, and Windows Servers communicate seamlessly with the firewall through the VPN. The absence of client software on these servers simplifies the overall deployment and maintenance.

In essence, this traditional VPN setup offers a straightforward and common approach to secure network communication, making resources accessible without the need for additional client software.

### **Overlay Networks: The New Contenders**

![Overlay Network VPN System](/assets/img/2024/posts/overlay-vpn-architecture.webp)

In the realm of [Tailscale](https://tailscale.com/){:target='_blank'}, understanding the intricacies of device connectivity is crucial. Let's delve into the technical framework where your Linux server takes center stage, acquiring a local IP address and a persistent overlay IP. This overlay IP, a static identifier, ensures continuity even amidst changes in the local address.

#### **Operational Mechanism**

Picture yourself within any network environment; the local IP functions conventionally. However, the overlay IP introduces stability. You, your system, and other network entities engage with the coordination server.

**The Coordination Server**

- As the pivotal component, this server houses and enforces the predefined rules. It serves as the authoritative entity ensuring seamless interactions. While not mandatory to reside in the cloud, Tailscale and ZeroTier offer server solutions. The server orchestrates connections based on specified rules, dictating communication paths.

**Mesh Networking Dynamics**

- Distinguishing itself, this setup operates as a mesh network. The coordination server refrains from data intervention; instead, it guides devices on establishing direct communication pathways. Tailscale's detailed explanation of UDP hole punching adds depth to the technical understanding.

**Localized Interaction**

- An intriguing aspect emerges when devices share the same local network. In this scenario, direct communication occurs, bypassing the coordination server. Yet, a consideration arises – the discreet handling of NAS and printer resources.

**Role of Agents**

- Enabling this orchestrated symphony necessitates an agent on each device, acting as the gateway to the network ecosystem. Remarkably, whether your assets reside in the cloud or across multiple offices, a uniform set of rules applies, accommodating various locations seamlessly.

**Agent Variants**

- **pfSense Integration:** pfSense assumes a pivotal role as an intermediary. Communication with the coordination server grants local network access without the requirement for individual agents.

- **Headscale Implementation:** A self-hosted alternative to Tailscale, [Headscale](https://headscale.net/){:target='_blank'} empowers users to manage their coordination server. This provides autonomy over authentication processes.

**Trust Dynamics:**

- While the encryption secures data in transit, placing trust in the coordination server is paramount. Functioning as the gatekeeper, it determines device authentication within the network. A cautious approach is advised, avoiding indiscriminate allocation of access privileges.

### **Cloudflare Tunnels: A VPN Replacement?**

As our exploration continues, we touch upon [Cloudflare Tunnels](https://www.cloudflare.com/products/tunnel/){:target='_blank'}, a solution that challenges the traditional VPN paradigm. While not a direct VPN killer, Cloudflare Tunnels expose internal resources publicly, eliminating the need for a VPN altogether. However, caution is advised, as trust in Cloudflare becomes integral to this approach.

### **The Verdict: A Matter of Perspective**

In conclusion, are overlay networks the VPN killer? The answer lies in perspective. Overlay networks, while introducing a new approach, still operate on VPN principles. The debate on whether they replace traditional VPNs or serve as complementary solutions is ongoing.

### **Further Exploration: In-Depth Tutorials**

For those hungry for more details, explore links below:

- [How Tailscale works](https://tailscale.com/blog/how-tailscale-works){:target='_blank'}

- [How NAT traversal works](https://tailscale.com/blog/how-nat-traversal-works){:target='_blank'}
