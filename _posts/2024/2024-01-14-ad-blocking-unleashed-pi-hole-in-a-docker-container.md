---
layout: post
title: 'Ad Blocking Unleashed: Pi-hole in a Docker Container'
image:
  path: "/assets/img/2024/thumbs/ad-blocking-unleashed.webp"
categories:
- Self-hosted
tags:
- Docker
- Pi-hole
date: 2024-01-14 23:54 +0200
---
[Pi-hole](https://pi-hole.net){: target="_blank"} is a versatile and powerful network-wide ad blocker that also functions as a recursive Domain Name System (DNS) server. It is designed to be deployed on a local network to block unwanted advertisements, tracking, and other undesirable content at the network level. Pi-hole operates as a DNS sinkhole, meaning it intercepts DNS requests and filters out requests for domains known to host advertisements and malicious content.

### How It Works

![Homelab Containers Pi-hole How It Works](/assets/img/2023/posts/homelab-containers-pihole-howitworks.webp)

In its standard configuration, Pi-hole functions as a forwarding DNS server. This means it possesses a specific list of websites with corresponding IP addresses for resolution. If it encounters a request for a website not on its list, Pi-hole will forward the request to the next configured DNS provider.

For instance, when you input `hackaday.com` in your web browser, the request is forwarded to Pi-hole. As `hackaday.com` isn't in Pi-hole's list, it forwards the request to the next DNS server you've set up. This server then returns the IP address for `hackaday.com` through Pi-hole to your PC. However, during the loading process, `hackaday.com` may attempt to load additional websites containing ads. Pi-hole, with its adblock list, filters out these ad-related requests, enhancing your browsing experience.

### Installation


We will be using Docker Compose file for setting up Pi-hole with Unbound as a DNS resolver. You can visit official [Github](https://github.com/pi-hole/docker-pi-hole/#running-pi-hole-docker){: target="_blank"} repo with instructions.

#### Installing on Ubuntu or Fedora

Modern releases of Ubuntu (17.10+) and Fedora (33+) include [`systemd-resolved`](http://manpages.ubuntu.com/manpages/bionic/man8/systemd-resolved.service.8.html){: target="_blank"} which is configured by default to implement a caching DNS stub resolver. This will prevent pi-hole from listening on port 53.
The stub resolver should be disabled with:

```bash
sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
```

This will not change the nameserver settings, which point to the stub resolver thus preventing DNS resolution. Change the `/etc/resolv.conf` symlink to point to `/run/systemd/resolve/resolv.conf`, which is automatically updated to follow the system's [`netplan`](https://netplan.io/){: target="_blank"}:

```bash
sudo sh -c 'rm /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'
```

After making these changes, you should restart systemd-resolved using:

```bash
systemctl restart systemd-resolved
```

Now, we can continue with running `docker-compose.yml` file:

```bash
docker-compose up -d
```

> Do not forget to create `pihole-data`, `pihole-dns`, `unbound` volume folders before starting containers.
{: .prompt-info}

You can access the Pi-hole service on `http://192.168.1.11:8888/admin/`.

Use this command to set or reset the Web interface Password:

```bash
docker exec -it pihole_container_name pihole -a -p
```

```yaml
version: "3.8"
services:
  unbound:
    image: mvance/unbound:latest
    container_name: unbound
    restart: unless-stopped
    hostname: unbound
    volumes:
      - unbound:/opt/unbound/etc/unbound/
    networks:
      private_network:
        ipv4_address: 10.2.0.200
    cap_add:
      - NET_ADMIN
    env_file: .env

  pihole:
    depends_on:
      - unbound
    container_name: pihole
    image: pihole/pihole:latest
    restart: unless-stopped
    hostname: pihole
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "67:67/udp" # Only required if you are using Pi-hole as your DHCP server
      - "8888:80/tcp"
    dns:
      - 127.0.0.1
      - ${PIHOLE_DNS}
    volumes:
      - pihole-data:/etc/pihole/
      - pihole-dns:/etc/dnsmasq.d/
    cap_add:
      - NET_ADMIN
    networks:
      private_network:
        ipv4_address: 10.2.0.100
    env_file: ./.env

# Docker Networks
networks:
  private_network:
    ipam:
      driver: default
      config:
        - subnet: 10.2.0.0/24

# Docker Volumes
volumes:
  pihole-data:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '$VOLUME_PATH/pihole/etc-pihole'
  pihole-dns:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '$VOLUME_PATH/pihole/etc-dnsmasq.d'
  unbound:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '$VOLUME_PATH/unbound'
```
{: file="docker-compose.yml"}

.Env file example:

```vim
# Volume Path
VOLUME_PATH=~/homelab-containers/

# User and group identifiers
# User ID
PUID=1000
# Group ID
PGID=1000

# Network settings
# Subnet for the private network - NOT USED IN COMPOSE FILE, CAN BE REMOVED
# SUBNET=10.2.0.0/24

# Static IP for Unbound
UNBOUND_IPV4_ADDRESS=10.2.0.200
# Static IP for Pi-hole
PIHOLE_IPV4_ADDRESS=10.2.0.100

# Pi-hole settings
# Web password for Pi-hole, set to a secure password
WEBPASSWORD=

# IP address for the Unbound server used by Pi-hole
PIHOLE_DNS=10.2.0.200
```

In order to Unbound work properly we need to write our own configuration, lucky for us there is an example on the [pi-hole website](https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound){: target="_blank"}.

Finally, configure Pi-hole to use your recursive DNS server by specifying `10.2.0.200` as the Custom DNS (IPv4) and uncheck any Forwarding DNS's:

![Homelab Containers Pi-hole How It Works](/assets/img/2023/posts/homelab-containers-pihole-recursive-dns.webp)

> In the DNS settings in the web UI you can either set the resolver to `Allow only local requests` OR you can set it to `Bind only to interface eth0` if you set it to `Bind only to interface eth0` it appears to drop the warnings AND the allows a system to work.
{: .prompt-tip}


#### Wildcard DNS in Pi-hole

Wildcard DNS, for those who don't know, is a technique that enables any type of host name to share the same IP address as its DNS name. For instance, if my domain is `jokerwrld.win` and my IP is `1.2.3.4`, the record `lab.jokerwrld.win` will also share the same IP: `1.2.3.4`. This is particularly useful in various scenarios where you're managing numerous containers, such as in Kubernetes, OpenShift, Rancher, etc.

The issue with Pi-Hole is that it’s possible to add a Wildcard DNS, but not through the GUI, only through the shell.

So, how do we add Wildcard DNS to Pi-Hole on our homelab? Follow these steps:

1. Login to your pi-hole and go to `/etc/dnsmasq.d/`

2. Create a new file, lets call it `02-my-wildcard-dns.conf`

3. Edit the file, and add a line like this:

    ```vim
    address=/home.jokerwrld.win/192.168.1.20
    ```

4. Save the file, and exit the editor

5. Run the command:

    ```bash
    service pihole-FTL restart
    ```
