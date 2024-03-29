---
layout: post
title: 'Nginx Proxy Manager Unveiled: A Secure Journey with SSL and Reverse Proxy'
image:
  path: "/assets/img/2024/thumbs/nginx-proxy-manager.webp"
categories:
- Self-hosted
- Networking
tags:
- Linux
- Docker
- Nginx Proxy Manager
date: 2024-01-15 00:14 +0200
---
[Nginx Proxy Manager](https://nginxproxymanager.com/guide/#project-goal){: target="_blank"} is a powerful open-source tool designed to simplify the configuration and management of reverse proxy servers. In a world where web applications and services are becoming increasingly complex, Nginx Proxy Manager offers an intuitive and user-friendly interface to efficiently route traffic, manage SSL certificates, and streamline the deployment of web applications.

## Installation

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

## Getting Started

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

## Generating the SSL Certificates

When setting up SSL certificates for Nginx Proxy Manager, it's essential to have a registered domain name. You can obtain a free domain from [Duck DNS](https://www.duckdns.org/){: target="_blank"} or purchase a custom one. In my case, I'll be using a domain from [Cloudflare](https://www.cloudflare.com/){: target="_blank"}.

- **DNS Management**

  Create an A record pointing your domain to the public IP address of your proxy instance. Additionally, establish CNAME records for all subdomains, directing them accordingly.

  ![Homelab Containers NPM Cloudflare DNS](/assets/img/2023/posts/homelab-containers-npm-cloudflare-dns.webp)

- **SSL Certificates**

  In the Nginx Proxy Manager web interface, navigate to the `SSL Certificates` tab, and add a new SSL certificate and select the domain for which you created the A record and CNAME records.

  ![Homelab Containers NPM SSL Certs](/assets/img/2023/posts/homelab-containers-npm-ssl-certs.webp)

  > Nginx Proxy Manager and Let's Encrypt will automatically handle SSL certificate renewal. Ensure that your Cloudflare settings remain intact to allow the renewal process.
  {: .prompt-tip}

## Setting Up Domains

Now we can add our proxy entries.

- **Domain Names**

  The domain name is going to be our root or sub domain, so `SERVICE_NAME.home.jokerwrld.win`.

- **Forward Hostname/IP**

  In this field we don't need actually have to put any IP addresses we can just refer to a containers using their names in the `docker-compose.yml` file.

  If you want to proxy a non-docker service, or maybe if your service is not on the same Docker network as the Nginx Proxy Manager, you'll need to put the IP address instead. For example, if your service is running on the same machine as the Nginx Proxy Manager, that will be localhost e.g. `127.0.0.1` and also port on which is service running on.

- **Other Options**

  Depending on the application, you also might want to enable some of these options.

  For example, Home Assistant, TrueNAS Scale, and Proxmox uses `Websockets`, so you'll want to enable them in that case.

  `Block Common Exploits` is not that useful, since we're running our proxy on the local network, behind a firewall and CGNAT.

  And `Cache Assets` also doesn't make much of a difference in speed in my opinion.

  After that's done, we can go to the `SSL` tab, and choose the SSL certificate that we've generated earlier. Also, we'll enable `Force SSl` and `HTTP/2 Support`.

  ![Homelab Containers NPM Proxy Host](/assets/img/2023/posts/homelab-containers-npm-proxy-host.webp)

## Accessing Local Service

Now we can open the URL. And there you go! A local service running in your home network with a pretty domain name and a valid SSL certificate.

![Homelab Containers NPM Local Service](/assets/img/2023/posts/homelab-containers-npm-local-service.webp)

> This method relies on the Internet connection to resolve the domains. So if you want your services to work independently of the Internet connection, that's where you might want to run your own DNS server like [Pi-Hole](https://pi-hole.net/){: target="_blank"} or [AdGuard](https://github.com/AdguardTeam/AdGuardHome#getting-started){: target="_blank"}.
{: .prompt-info}