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



## Dashy


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

## Cloudflare Tunnel

## TrueNAS Scale

## MediaFile hosting Next Cloud

## Gaming server
