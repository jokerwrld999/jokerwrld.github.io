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
[Homepage](https://gethomepage.dev/latest/){:target='_blank'}





## Installation on LXC

Current installation setup involves docker container and tailscale container with `network_mode`. This setup helps Homepage to access various services through Tailscale Tunnel. Tailscale Docker container needs `/dev/net/tun` device to be mounted on LXC.

1. **Install Docker LXC:**

    - Start by creating an Docker LXC container within Proxmox. You can get it from [Proxmox VE Helper-Scripts](https://tteck.github.io/Proxmox/){:target='_blank'}

    - To create a new Proxmox VE Docker LXC, run the command bellow in the `Proxmox VE Shell`:

    ```bash
    bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/ct/docker.sh)"
    ```

6. **Enable Tun device on LXC:**

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


7. **Run Docker Compose:**

    {::options parse_block_html='true' /}
    <details>
      <summary markdown='span'>Homepage Docker Compose File</summary>

      ```yaml
      ---
      version: '3.8'
      services:
        tailscale:
          container_name: tailscale
          hostname: tailscale-homepage
          image: tailscale/tailscale:latest
          restart: unless-stopped
          ports:
            - '3000:3000'
          environment:
            - TS_AUTHKEY=$TS_AUTHKEY
            - TS_EXTRA_ARGS=--accept-routes
            - TS_STATE_DIR=/var/lib/tailscale
            - TS_USERSPACE=false
          volumes:
            - tailscale-state:/var/lib/tailscale
            - /dev/net/tun:/dev/net/tun
          cap_add:
            - net_admin
            - sys_module
        homepage:
          container_name: homepage
          image: ghcr.io/gethomepage/homepage:latest
          depends_on:
            - tailscale
          restart: unless-stopped
          env_file:
            - ./.env
          volumes:
            - homepage-config:/app/config
            - /var/run/docker.sock:/var/run/docker.sock:ro
          network_mode: service:tailscale

      # Docker Volumes
      volumes:
        homepage-config:
          driver: local
          driver_opts:
            type: 'none'
            o: 'bind'
            device: '$VOLUME_PATH/homepage/config'
        tailscale-state:
          driver: local
          driver_opts:
            type: 'none'
            o: 'bind'
            device: '$VOLUME_PATH/tailscale/state'
      ```

    </details>
    {::options parse_block_html='false' /}


    ```bash
    docker compose up -d --force-recreate
    ```

8. **Create Nginx Configuration:**

    ```bash
    vim /etc/nginx/sites-available/homepage
    ```


  - Update Config

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

    ```bash
    ln -s /etc/nginx/sites-available/homepage /etc/nginx/sites-enabled/
    ```

11. Restart Nginx

    ```yaml
    nginx -t
    systemctl restart nginx
    ```
