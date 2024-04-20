---
layout: post
title: Ultimate Homepage Dashboard
image:
  path: "/assets/img/2024/thumbs/default.webp"
categories:
- Self-hosted
- Project
- Guide
tags:
- Git
- Linux
- Bash
- Nginx
- Docker
---


## Installation

1. **Install Docker LXC:**

    ```bash
    bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/docker.sh)"
    ```

2. **Clone Repository:**

    ```bash
    mkdir ~/github && cd ~/github
    git clone "https://github.com/jokerwrld999/homelab-containers.git" && cd homelab-containers/homepage
    ```

3. **Install Python Dependencies:**

    ```bash
     apt install vim python-is-python3 python3-pip nginx -y
     echo "alias pip='pip3'" >> ~/.bashrc
     source ~/.bashrc
     pip install --upgrade pip
     pip install -r ../requirements.txt
     python3 ../volumes.py
    ```

5. **Copy Configurations Files:**

    ```bash
    cp -R ./config/* ~/homelab-containers/homepage/config/
    ```
4. **Update `.env` file:**

    ```vim
    vim .env
    ```
    
6. Enable Tun on LXC
    
    ```bash
    vim /etc/pve/lxc/250.conf
    ```
    
    ```yaml
    lxc.cgroup.devices.allow: c 10:200 rwm
    lxc.mount.entry: /dev/net dev/net none bind,create=dir
    ```
    
    ```yaml
    pct reboot 250
    ```
    
7. Run Docker Compose
    
    ```jsx
    docker compose up -d --force-recreate
    ```
    
8. Create Nginx Configuration
    
    ```jsx
    vim /etc/nginx/sites-available/homepage
    ```
    
9. Update Config
    
    ```vim
    server {
        listen 80;
        listen [::]:80;
    
        server_name homepage.home.jokerwrld.win;
    
        location / {
            proxy_pass http://127.0.0.1:3000;
            include proxy_params;
        }
    }
    ```
    
10. Enable Site
    
    ```jsx
    ln -s /etc/nginx/sites-available/homepage /etc/nginx/sites-enabled/
    ```
    
11. Restart Nginx
    
    ```yaml
    nginx -t
    systemctl restart nginx
    ```
    