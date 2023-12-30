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

Stop and remove service containers
```bash
docker-compose rm -svf service
```


## Nginx Proxy Manager

[Nginx Proxy Manager](https://nginxproxymanager.com/guide/#project-goal){: target="_blank"} is a powerful open-source tool designed to simplify the configuration and management of reverse proxy servers. In a world where web applications and services are becoming increasingly complex, Nginx Proxy Manager offers an intuitive and user-friendly interface to efficiently route traffic, manage SSL certificates, and streamline the deployment of web applications.

### Installation

The installation process is straightforward, and using Docker Compose allows the service to be deployed within moments.

```yaml
---
version: '3.8'
services:
  # Nginx Proxy Manager
  nginx-proxy-manager:
    container_name: nginx_proxy_manager
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '81:81'
      - '443:443'
    environment:
      DB_MYSQL_HOST: "npm_db"
      DB_MYSQL_PORT: 3306
      DB_MYSQL_USER: "npm"
      DB_MYSQL_PASSWORD: "npm"
      DB_MYSQL_NAME: "npm"
    volumes:
      - nginx-proxy-manager-data:/data
      - nginx-proxy-manager-certs:/etc/letsencrypt
    networks:
      - services

  # Database For NPM
  db:
    container_name: npm_db
    image: 'jc21/mariadb-aria:latest'
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: 'npm'
      MYSQL_DATABASE: 'npm'
      MYSQL_USER: 'npm'
      MYSQL_PASSWORD: 'npm'
    volumes:
      - nginx-proxy-manager-db:/var/lib/mysql
    networks:
      - services

# Docker Networks
networks:
  services:
    driver: bridge

# Docker Volumes
volumes:
  nginx-proxy-manager-data:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '$VOLUME_PATH/nginx_proxy_manager/npm_data'
  nginx-proxy-manager-db:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '$VOLUME_PATH/nginx_proxy_manager/npm_db'
  nginx-proxy-manager-certs:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '$VOLUME_PATH/nginx_proxy_manager/npm_certs'
```
{: file="docker-compose.yml"}

### Getting Started

- Deploy Nginx Proxy Manager Service:

  Open a terminal, navigate to the directory with `docker-compose.yml` file, and run the following command to start the containers:

  ```bash
  docker-compose up -d
  ```

- Access NPM Service:

  Nginx Proxy Manager should now be accessible at `http://localhost:81` or `https://SERVER_IP`.

  Default Admin User:

  ```
  Email:    admin@example.com
  Password: changeme
  ```

  ![Homelab Containers Nginx Proxy Manager](/assets/img/2023/posts/homelab-containers-npm-login.webp)

### Generating the SSL Certificates

When setting up SSL certificates for Nginx Proxy Manager, it's essential to have a registered domain name. You can obtain a free domain from [Duck DNS](https://www.duckdns.org/){: target="_blank"} or purchase a custom one. In my case, I'll be using a domain from [Cloudflare](https://www.cloudflare.com/){: target="_blank"}.

- **DNS Management**

  Create an A record pointing your domain to the public IP address of your proxy instance. Additionally, establish CNAME records for all subdomains, directing them accordingly.

  ![Homelab Containers NPM Cloudflare DNS](/assets/img/2023/posts/homelab-containers-npm-cloudflare-dns.webp)

- **SSL Certificates**

  In the Nginx Proxy Manager web interface, navigate to the `SSL Certificates` tab, and add a new SSL certificate and select the domain for which you created the A record and CNAME records.

  ![Homelab Containers NPM SSL Certs](/assets/img/2023/posts/homelab-containers-npm-ssl-certs.webp)

  > Nginx Proxy Manager and Let's Encrypt will automatically handle SSL certificate renewal. Ensure that your Cloudflare settings remain intact to allow the renewal process.
  {: .prompt-tip}

### Setting Up Domains

Now we can add our proxy entries.

- **Domain Names**

  The domain name is going to be our root or sub domain, so `SERVICE_NAME.home.jokerwrld.win`.

- **Forward Hostname/IP**

  In this field we don't need actually have to put any IP addresses we can just refer to a containers using their names in the `docker-compose.yml` file.

  If you want to proxy a non-docker service, or maybe if your service is not on the same Docker network as the Nginx Proxy Manager, you'll need to put the IP address instead. For example, if your service is running on the same machine as the Nginx Proxy Manager, that will be localhost e.g. `127.0.0.1` and also port on which is service running on.

- **Other Options**

  Depending on the application, you also might want to enable some of these options.

  For example, Home Assistant uses `Websockets`, so you'll want to enable them in that case.

  `Block Common Exploits` is not that useful, since we're running our proxy on the local network, behind a firewall and CGNAT.

  And `Cache Assets` also doesn't make much of a difference in speed in my opinion.

  After that's done, we can go to the `SSL` tab, and choose the SSL certificate that we've generated earlier. Also, we'll enable `Force SSl` and `HTTP/2 Support`.

  ![Homelab Containers NPM Proxy Host](/assets/img/2023/posts/homelab-containers-npm-proxy-host.webp)

### Accessing Local Service

Now we can open the URL. And there you go! A local service running in your home network with a pretty domain name and a valid SSL certificate.

![Homelab Containers NPM Local Service](/assets/img/2023/posts/homelab-containers-npm-local-service.webp)

> This method relies on the Internet connection to resolve the domains. So if you want your services to work independently of the Internet connection, that's where you might want to run your own DNS server like [Pi-Hole](https://pi-hole.net/){: target="_blank"} or [AdGuard](https://github.com/AdguardTeam/AdGuardHome#getting-started){: target="_blank"}.
{: .prompt-info}

## Jenkins

[Jenkins](https://www.jenkins.io/){: target="_blank"} is an open-source automation server widely used for building, testing, and deploying software. Developed in Java and launched in 2011, Jenkins has become a key tool in the DevOps toolchain, enabling continuous integration and continuous delivery (CI/CD) practices.

### Getting Started

This documentation aims to guide you through the process of deploying Jenkins with Docker support and [Blue Ocean](https://www.jenkins.io/doc/book/blueocean/#blue-ocean-overview){: target="_blank"} plugin out-of-box using Docker Compose, providing a quick and easy setup for local development and testing.

- **Jenkins Server**

  We'll need to build a custom Dockerfile to customize a Jenkins image and make some modifications, including installing Docker CLI, adding Blue Ocean Jenkins plugin.

  ```Dockerfile
  FROM jenkins/jenkins:latest

  USER root

  RUN apt-get update && apt-get install -y lsb-release

  RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc https://download.docker.com/linux/debian/gpg

  RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

  RUN apt-get update && apt-get install -y docker-ce-cli

  USER jenkins
  RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"

  ENV DOCKER_HOST=tcp://docker:2376
  ENV DOCKER_CERT_PATH=/certs/client
  ENV DOCKER_TLS_VERIFY=1

  EXPOSE 8080/tcp
  EXPOSE 5000/tcp
  ```
  {: file="jenkins_server.yml"}

- **Jenkins Docker In Docker**

  This Dockerfile will enable us to run Docker commands from within a Docker container. The exposed port `2376` is commonly used for secure communication with the Docker daemon. The `DOCKER_TLS_CERTDIR` environment variable is used to specify the directory where TLS certificates are stored.

  ```Dockerfile
  FROM docker:dind
  EXPOSE 2376/tcp
  ENV DOCKER_TLS_CERTDIR=/certs
  ```
  {: file="jenkins_dind.yml"}

- **Docker Compose**

  Now, we need to define two services: `jenkins-server` and `jenkins-docker-in-docker` in our Docker Compose file.

  ```yaml
  ---
  version: '3.8'
  services:
    # Jenkins Server
    jenkins-server:
      container_name: jenkins_server
      build:
        context: .
        dockerfile: ./jenkins/jenkins_server
      image: jenkins:built
      restart: unless-stopped
      volumes:
        - jenkins-data:/var/jenkins_home
        - jenkins-docker-certs:/certs/client:ro
      depends_on:
        - jenkins-docker-in-docker
      networks:
        - services

    # Jenkins Docker In Docker
    jenkins-docker-in-docker:
      container_name: jenkins_dind
      build:
        context: .
        dockerfile: ./jenkins/jenkins_dind
      image: jenkins_dind:built
      restart: unless-stopped
      privileged: true
      volumes:
        - jenkins-docker-certs:/certs/client
        - jenkins-data:/var/jenkins_home
      networks:
        services:
          aliases:
            - docker

  # Docker Networks
  networks:
    services:
      driver: bridge

  # Docker Volumes
  volumes:
    jenkins-data:
      driver: local
      driver_opts:
        type: 'none'
        o: 'bind'
        device: '$VOLUME_PATH/jenkins/data'
    jenkins-docker-certs:
      driver: local
      driver_opts:
        type: 'none'
        o: 'bind'
        device: '$VOLUME_PATH/jenkins/certs'
  ```
  {: file="docker-compose.yml"}

  **NOTE:**

  - The aliases for the `docker` network in the `jenkins-docker-in-docker` service allow the Jenkins server to refer to the Docker daemon using the hostname `docker`.

  - Ensure that the `$VOLUME_PATH` variable is correctly set in your environment or replace it with the actual path where you want to store Jenkins data and Docker TLS certificates.

  Run the following command to start the containers:

  ```bash
  docker-compose up -d
  ```

- **Access Jenkins Web Interface**

  Once the containers are running, access Jenkins in your web browser at `http://localhost:8080`.

- **Unlock Jenkins**

  Retrieve the initial admin password:

  ```bash
  docker exec -it jenkins_server bash -c "cat /var/jenkins_home/secrets/initialAdminPassword"
  ```

### Creating First Jenkins Pipeline

Let's configure our first Jenkins pipeline by inserting the contents of our `Jenkinsfile` into the script area of the `Pipeline` job type.

```groovy
pipeline {
    agent any
    stages {
        stage('Check Docker installation') {
            steps {
                echo 'Checking for Docker...'
                sh '''
                docker ps
                '''
            }
        }
        stage('Build') {
            steps {
                echo 'Building...'
                sh '''
                echo "Doing build stuff..."
                '''
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
                sh '''
                echo "Doing test stuff..."
                '''
            }
        }
        stage('Deliver') {
            steps {
                echo 'Deliver...'
                sh '''
                echo "Doing delivery stuff..."
                '''
            }
        }
    }
}

```
{: file="Jenkinsfile"}

After running the pipeline we can view our results in Blue Ocean interface:

![Homelab Containers Jenkins First Pipeline](/assets/img/2023/posts/homelab-containers-jenkins-first-pipeline.webp)

## Pi-hole

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

```
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

1. Login to your pi-hole and go to /etc/dnsmasq.d/
2. Create a new file, lets call it 02-my-wildcard-dns.conf
3. Edit the file, and add a line like this:
address=/home.jokerwrld.win/192.168.1.20
4. Save the file, and exit the editor
5. Run the command: ```service pihole-FTL restart```

### File Systems Fundamentals

File system information is categorized into two main parts: data and metadata. Data comprises the actual blocks, records, or any other grouping that the file system uses to constitute a file. Metadata includes pieces of information describing a file, such as its reference, location, creation time, and permissions. While data is the content of the file, metadata provides essential details about the file itself.

#### Journaling File Systems

Journaling is a technique employed by many modern file systems, including NTFS, ext4, and XFS. The process involves maintaining a special log file known as the journal, where the file system records all its actions before executing them. The primary purpose of journaling is to enhance the reliability and recovery capabilities of the file system.

1. **Action Recording:**
   - Before performing any action, the file system records the action in the journal.

2. **Action Execution:**
   - The file system executes the action, whether it's creating, modifying, or deleting files or directories.

3. **Journal Investigation (In Case of Crash):**
   - If the operating system crashes during an action, the file system can investigate the journal on the next system boot.

4. **Completing Actions:**
   - The file system completes any actions recorded in the journal that were not finalized due to the crash.

#### Advantages of Journaling:

- **Enhanced Reliability:**
  - Journaling improves the reliability of file systems by providing a consistent and recoverable state, especially in the event of an unexpected system crash.

- **Faster Recovery:**
  - In case of a crash, the file system can quickly recover by examining the journal and completing any pending actions on the next system boot.

- **Metadata Integrity:**
  - Journaling primarily focuses on logging metadata changes, ensuring the integrity and consistency of critical file system information.

#### Use Cases for Journaling File Systems:

- **Operating System Integrity:**
  - Journaling is essential for the integrity of the operating system, ensuring that file system actions are completed even in the face of unexpected failures.

- **Transactional Systems:**
  - Journaling is commonly used in systems where transactional consistency is crucial, such as databases and critical server environments.

- **Data Recovery:**
  - The journaling process aids in the recovery of data and file system consistency after an unexpected system crash.

- **Critical File System Operations:**
  - Journaling is particularly beneficial for critical file system operations, where maintaining the integrity of metadata is vital.

#### Copy-on-Write

Copy-on-Write (COW) is a data storage strategy employed by some file systems and database systems to optimize resource utilization and improve system performance. The core idea behind Copy-on-Write is to defer the duplication (copying) of data until it is necessary, rather than making a redundant copy of data immediately. This approach is particularly useful in scenarios where data is frequently read and rarely modified.

Here's how Copy-on-Write typically works:

1. **Initial Read:**
   - When a piece of data needs to be read or accessed, the system does not create an immediate duplicate copy.

2. **Modification Request:**
   - If a write or modification operation is requested on the data, Copy-on-Write comes into play.

3. **Copy Operation:**
   - Instead of modifying the existing data in place, a new copy of the data is created. The modification is made to the copy.

4. **Update Reference:**
   - The reference to the original data is updated to point to the newly created copy.

Copy-on-Write has several advantages and use cases:

- **Efficiency in Read-Heavy Workloads:** In scenarios where data is predominantly read rather than modified, COW can be more efficient. It avoids unnecessary copying until a modification is needed.

- **Reduced Overhead:** Immediate duplication of data for write operations can lead to unnecessary storage overhead, especially if the data is never modified again. COW minimizes this overhead.

- **Snapshot Creation:** Copy-on-Write facilitates the efficient creation of snapshots. Since creating a snapshot involves copying only the modified data, it can be faster and less resource-intensive.

- **Consistency and Atomicity:** Copy-on-Write ensures that modifications are atomic. If a failure occurs during the write operation, the original data remains intact.

### ZFS

#### Zpools, vdevs, and devices

[How fast are your disks? Find out the open source way, with fio](https://arstechnica.com/gadgets/2020/02/how-fast-are-your-disks-find-out-the-open-source-way-with-fio/){:target="_blank"}

[ZFS 101—Understanding ZFS storage and performance](https://arstechnica.com/information-technology/2020/05/zfs-101-understanding-zfs-storage-and-performance/){:target="_blank"}

![Homelab Containers ZFS Architecture](/assets/img/2023/posts/homelab-containers-zfs-architecture.webp)

The ZFS (Zettabyte File System) architecture consists of several key components, each playing a crucial role in the organization and management of storage. Here's an overview of the terms and concepts related to ZFS:

1. **Zpool:**
   - A Zpool is the highest-level construct in ZFS, representing a storage pool that can contain one or more vdevs. Zpools are independent units, and each may consist of various vdevs.

2. **Vdev (Virtual Device):**
   - A vdev is a virtual device within a Zpool and is composed of one or more physical devices. Vdevs can have different topologies, including single-device, RAIDz1, RAIDz2, RAIDz3, or mirror. Each vdev is responsible for redundancy at its level, and the loss of a vdev can result in data loss for the entire Zpool.

3. **RAIDz:**
   - RAIDz1, RAIDz2, and RAIDz3 are specific types of vdevs in ZFS, implementing diagonal parity RAID. These RAIDz levels determine how many parity blocks are allocated to each data stripe, providing fault tolerance up to a certain number of disk failures.

4. **Mirror Vdev:**
   - A mirror vdev stores each block on every device within the vdev. It provides redundancy by duplicating data across multiple disks. A mirror vdev can withstand the failure of multiple devices, as long as at least one device remains healthy.

5. **Single-Device Vdev:**
   - A single-device vdev is composed of a single physical device. It is inherently risky, as it cannot survive any failures. If a single-device vdev fails, it can bring down the entire Zpool.

6. **CACHE, LOG, and SPECIAL Vdevs:**
   - These are special types of vdevs that serve specific purposes:
      - **CACHE Vdev:** Used for read and write caching.
      - **LOG Vdev:** Used for synchronous transaction logging to improve write performance.
      - **SPECIAL Vdev:** Used for devices that require dedicated storage, and their failure can result in the loss of the entire Zpool.

7. **Device:**
   - A device in ZFS is a random-access block device, typically a disk (HDD or SSD). Devices can be organized into vdevs, which, in turn, form Zpools. ZFS also supports the use of entire hardware RAID arrays as individual devices.

8. **Raw File:**
   - A simple raw file is an alternative block device that can be used to create vdevs in ZFS. This allows users to practice ZFS commands and test pool configurations using sparse files.

Understanding these ZFS terms is crucial for effectively managing storage with ZFS and making informed decisions about pool and vdev configurations based on redundancy and performance requirements.

#### Datasets, blocks, and sectors

![Homelab Containers ZFS Datasets](/assets/img/2023/posts/homelab-containers-zfs-datasets.webp)

In the context of storage systems and file systems, datasets, blocks, and sectors are terms that refer to different levels of data organization and storage.

1. **Dataset:**
   - A dataset is a collection of related data or files. In file systems, a dataset is often synonymous with a directory or folder that contains files. However, in some storage systems, especially in the context of ZFS, a dataset can be more than just a directory; it can represent a more complex structure with properties and settings.

2. **Blocks:**
   - Blocks are units of storage used by file systems to manage data. A block is typically a fixed-size allocation of storage space, and it is the minimum amount of data that can be read or written at a time. File systems organize data into blocks to efficiently manage storage and facilitate data retrieval. The block size can vary depending on the file system and the configuration.

3. **Sectors:**
   - Sectors are the smallest addressable unit on a physical storage device such as a hard disk drive (HDD) or a solid-state drive (SSD). A sector is a fixed-size unit of storage on the disk surface. Historically, the standard sector size was 512 bytes, but modern storage devices often use larger sector sizes, such as 4 KB (4096 bytes).

In summary, datasets represent collections of related data or files, blocks are units of storage used by file systems for data management, and sectors are the smallest addressable units on physical storage devices. The concepts of datasets and blocks are more closely associated with file systems and logical data organization, while sectors are a lower-level concept related to the physical structure of storage devices. Understanding these terms is essential for effectively managing and organizing data in storage systems.



## TrueNAS Scale


## Cloudflare Tunnel
## Rancher

## MediaFile hosting Next Cloud

## Gaming server