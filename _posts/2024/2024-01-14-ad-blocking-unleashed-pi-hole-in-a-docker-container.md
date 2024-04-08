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

## How It Works

![Homelab Containers Pi-hole How It Works](/assets/img/2023/posts/homelab-containers-pihole-howitworks.webp)

In its standard configuration, Pi-hole functions as a forwarding DNS server. This means it possesses a specific list of websites with corresponding IP addresses for resolution. If it encounters a request for a website not on its list, Pi-hole will forward the request to the next configured DNS provider.

For instance, when you input `hackaday.com` in your web browser, the request is forwarded to Pi-hole. As `hackaday.com` isn't in Pi-hole's list, it forwards the request to the next DNS server you've set up. This server then returns the IP address for `hackaday.com` through Pi-hole to your PC. However, during the loading process, `hackaday.com` may attempt to load additional websites containing ads. Pi-hole, with its adblock list, filters out these ad-related requests, enhancing your browsing experience.

## Installation


We will be using Docker Compose file for setting up Pi-hole with Unbound as a DNS resolver. You can visit official [Github](https://github.com/pi-hole/docker-pi-hole/#running-pi-hole-docker){: target="_blank"} repo with instructions.

### Installing on Ubuntu or Fedora

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


### Wildcard DNS in Pi-hole

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

## Pi-hole In LXC Container

1. **Create Ubuntu LXC:**

    - Start by creating an Ubuntu LXC container within Proxmox. You can get it from [Proxmox VE Helper-Scripts](https://tteck.github.io/Proxmox/){:target='_blank'}

    - To create a new Proxmox VE Ubuntu LXC, run the command bellow in the `Proxmox VE Shell`.

    ```bash
    bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/ubuntu.sh)"
    ```

2. **Install Pi-hole and Unbound:**

    - Run a command in the newly created `LXC Container` to automatically install Pi-hole.

    ```bash
    curl -sSL https://install.pi-hole.net | bash
    ```

    - Install the Unbound recursive DNS resolver.

    [Unbound DNS](https://github.com/anudeepND/pihole-unbound){:target='_blank'}

    - Disable the stub resolver as showed before on Ubuntu.

3. **Add Tailscale into LXC:**

    [Tailscale in LXC](https://tailscale.com/kb/1130/lxc-unprivileged){:target='_blank'}

    - By adding Tailscale into your LXC Container you can use Pi-hole as your Ad-blocker and DNS caching solution across all of your connected devices.

4. **Add Pi-hole to your Tailscale nameservers:**

    - Now you can add your Pi-hole to Tailscale's global nameservers.

    [Pi-hole and Tailscale](https://tailscale.com/kb/1114/pi-hole){:target='_blank'}

5. **Expand Pi-hole's Ad-block list:**

    - Log in to your Pi-hole Admin UI and update `Adlists` with lists from `firebog.net`.

    [Big Blocklist](https://firebog.net/){:target='_blank'}

    ```vim
    https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt
    https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts
    https://v.firebog.net/hosts/static/w3kbl.txt
    https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt
    https://someonewhocares.org/hosts/zero/hosts
    https://raw.githubusercontent.com/VeleSila/yhosts/master/hosts
    https://winhelp2002.mvps.org/hosts.txt
    https://v.firebog.net/hosts/neohostsbasic.txt
    https://raw.githubusercontent.com/RooneyMcNibNug/pihole-stuff/master/SNAFU.txt
    https://paulgb.github.io/BarbBlock/blacklists/hosts-file.txt
    https://adaway.org/hosts.txt
    https://v.firebog.net/hosts/AdguardDNS.txt
    https://v.firebog.net/hosts/Admiral.txt
    https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt
    https://v.firebog.net/hosts/Easylist.txt
    https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext
    https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts
    https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts
    https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts
    https://v.firebog.net/hosts/Easyprivacy.txt
    https://v.firebog.net/hosts/Prigent-Ads.txt
    https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts
    https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt
    https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt
    https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt
    https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/android-tracking.txt
    https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/SmartTV.txt
    https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/AmazonFireTV.txt
    https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-blocklist.txt
    https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt
    https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt
    https://v.firebog.net/hosts/Prigent-Crypto.txt
    https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts
    https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt
    https://phishing.army/download/phishing_army_blocklist_extended.txt
    https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt
    https://v.firebog.net/hosts/RPiList-Malware.txt
    https://v.firebog.net/hosts/RPiList-Phishing.txt
    https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt
    https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts
    https://urlhaus.abuse.ch/downloads/hostfile/
    https://malware-filter.gitlab.io/malware-filter/phishing-filter-hosts.txt
    https://v.firebog.net/hosts/Prigent-Malware.txt
    https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser
    https://raw.githubusercontent.com/chadmayfield/my-pihole-blocklists/master/lists/pi_blocklist_porn_top1m.list
    https://v.firebog.net/hosts/Prigent-Adult.txt
    https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt
    ```

6. **Whitelist false positive domains:**

    - When you add a lot of domains to your adlist there's probability of false positives, so it is recommended to add some commonly white listed domains. Here is the link to an awesome github repository with unattended setup.

    [White List Pi-hole](https://github.com/anudeepND/whitelist){:target='_blank'}
