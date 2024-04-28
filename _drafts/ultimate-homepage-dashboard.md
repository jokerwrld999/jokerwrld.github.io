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

    - Edit LXC's config file in the `Proxmox VE Shell`:

    ```bash
    vim /etc/pve/lxc/250.conf
    ```

    - Add the following lines into config:

    ```
    lxc.cgroup.devices.allow: c 10:200 rwm
    lxc.mount.entry: /dev/net dev/net none bind,create=dir
    ```

    - Reboot the container:

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

    {::options parse_block_html='true' /}
    <details>
      <summary markdown='span'>Services Configuration</summary>
    
      ```yaml
      ---
      - Hypervisors:
          - Proxmox-Home-PVE1:
              icon: proxmox.svg
              href: "{{HOMEPAGE_VAR_HOME_PVE1_PROXMOX_URL}}"
              description: "{{HOMEPAGE_VAR_HOME_PVE1_PROXMOX_DESCRIPTION}}"
              widget:
                  type: proxmox
                  url: "{{HOMEPAGE_VAR_HOME_PVE1_PROXMOX_URL}}"
                  username: "{{HOMEPAGE_VAR_HOME_PVE1_PROXMOX_USER}}"
                  password: "{{HOMEPAGE_VAR_HOME_PVE1_PROXMOX_API_KEY}}"
                  node: "{{HOMEPAGE_VAR_HOME_PVE1_PROXMOX_NODE}}"

          - Proxmox-Work-PVE1:
              icon: proxmox.svg
              href: "{{HOMEPAGE_VAR_WORK_PVE1_PROXMOX_URL}}"
              description: "{{HOMEPAGE_VAR_WORK_PVE1_PROXMOX_DESCRIPTION}}"
              widget:
                  type: proxmox
                  url: "{{HOMEPAGE_VAR_WORK_PVE1_PROXMOX_URL}}"
                  username: "{{HOMEPAGE_VAR_WORK_PVE1_PROXMOX_USER}}"
                  password: "{{HOMEPAGE_VAR_WORK_PVE1_PROXMOX_API_KEY}}"
                  node: "{{HOMEPAGE_VAR_WORK_PVE1_PROXMOX_NODE}}"

          - Proxmox-Work-PVE2:
              icon: proxmox.svg
              href: "{{HOMEPAGE_VAR_WORK_PVE2_PROXMOX_URL}}"
              description: "{{HOMEPAGE_VAR_WORK_PVE2_PROXMOX_DESCRIPTION}}"
              widget:
                  type: proxmox
                  url: "{{HOMEPAGE_VAR_WORK_PVE2_PROXMOX_URL}}"
                  username:  "{{HOMEPAGE_VAR_WORK_PVE2_PROXMOX_USER}}"
                  password:  "{{HOMEPAGE_VAR_WORK_PVE2_PROXMOX_API_KEY}}"
                  node: "{{HOMEPAGE_VAR_WORK_PVE2_PROXMOX_NODE}}"

          - Proxmox-Work-PVE3:
              icon: proxmox.svg
              href: "{{HOMEPAGE_VAR_WORK_PVE3_PROXMOX_URL}}"
              description: "{{HOMEPAGE_VAR_WORK_PVE3_PROXMOX_DESCRIPTION}}"
              widget:
                  type: proxmox
                  url: "{{HOMEPAGE_VAR_WORK_PVE3_PROXMOX_URL}}"
                  username: "{{HOMEPAGE_VAR_WORK_PVE3_PROXMOX_USER}}"
                  password: "{{HOMEPAGE_VAR_WORK_PVE3_PROXMOX_API_KEY}}"
                  node: "{{HOMEPAGE_VAR_WORK_PVE3_PROXMOX_NODE}}"

      # - Containers:
      #     - Rancher:
      #         icon: rancher.svg
      #         href: "{{HOMEPAGE_VAR_RACNHER_URL}}"
      #         description: "{{HOMEPAGE_VAR_RACNHER_DESCRIPTION}}"
      #     - Longhorn:
      #         icon: longhorn.svg
      #         href: "{{HOMEPAGE_VAR_LONGHORN_URL}}"
      #         description: "{{HOMEPAGE_VAR_LONGHORN_DESCRIPTION}}"

      - DNS:
          - Pi-Hole1:
              icon: pi-hole.svg
              href: "{{HOMEPAGE_VAR_PIHOLE1_URL}}/admin/"
              description: "{{HOMEPAGE_VAR_PIHOLE1_DESCRIPTION}}"
              widget:
                  type: pihole
                  url: "{{HOMEPAGE_VAR_PIHOLE1_URL}}"
                  key: "{{HOMEPAGE_VAR_PIHOLE1_API_KEY}}"

      - Network:
          - Uptime Kuma:
              icon: uptime-kuma.svg
              href: "{{HOMEPAGE_VAR_UPTIME_KUMA_URL}}"
              description: internal
              widget:
                  type: uptimekuma
                  url: "{{HOMEPAGE_VAR_UPTIME_KUMA_URL}}"
                  slug: home

          - Nginx Proxy Manager Home:
              icon: nginx-proxy-manager.svg
              href: "{{HOMEPAGE_VAR_HOME_NGINX_PROXY_MANAGER_URL}}"
              description: "{{HOMEPAGE_VAR_HOME_NGINX_PROXY_MANAGER_DESCRIPTION}}"
              widget:
                  type: npm
                  url: "{{HOMEPAGE_VAR_HOME_NGINX_PROXY_MANAGER_URL}}"
                  username: "{{HOMEPAGE_VAR_HOME_NGINX_PROXY_MANAGER_USERNAME}}"
                  password: "{{HOMEPAGE_VAR_HOME_NGINX_PROXY_MANAGER_PASSWORD}}"

          - Nginx Proxy Manager Work:
              icon: nginx-proxy-manager.svg
              href: "{{HOMEPAGE_VAR_WORK_NGINX_PROXY_MANAGER_URL}}"
              description: "{{HOMEPAGE_VAR_WORK_NGINX_PROXY_MANAGER_DESCRIPTION}}"
              widget:
                  type: npm
                  url: "{{HOMEPAGE_VAR_WORK_NGINX_PROXY_MANAGER_URL}}"
                  username: "{{HOMEPAGE_VAR_WORK_NGINX_PROXY_MANAGER_USERNAME}}"
                  password: "{{HOMEPAGE_VAR_WORK_NGINX_PROXY_MANAGER_PASSWORD}}"

      - Storage:
          - TrueNAS-Home:
              icon: truenas.svg
              href: "{{HOMEPAGE_VAR_HOME_TRUENAS_URL}}"
              description: "{{HOMEPAGE_VAR_HOME_TRUENAS_DESCRIPTION}}"
              widget:
                  type: truenas
                  url: "{{HOMEPAGE_VAR_HOME_TRUENAS_URL}}"
                  key: "{{HOMEPAGE_VAR_HOME_TRUENAS_API_KEY}}"

          - TrueNAS-Work:
              icon: truenas.svg
              href: "{{HOMEPAGE_VAR_WORK_TRUENAS_URL}}"
              description: "{{HOMEPAGE_VAR_WORK_TRUENAS_DESCRIPTION}}"
              widget:
                  type: truenas
                  url: "{{HOMEPAGE_VAR_WORK_TRUENAS_URL}}"
                  key: "{{HOMEPAGE_VAR_WORK_TRUENAS_API_KEY}}"

          - File Browser:
              icon: filebrowser.svg
              href: "{{HOMEPAGE_VAR_FILE_BROWSER_URL}}"
              description: "{{HOMEPAGE_VAR_FILE_BROWSER_DESCRIPTION}}"

      - Media:
          - NextCloud:
              icon: nextcloud.svg
              href: "{{HOMEPAGE_VAR_NEXTCLOUD_URL}}"
              description: "{{HOMEPAGE_VAR_NEXTCLOUD_DESCRIPTION}}"
              widget:
                  type: nextcloud
                  url: "{{HOMEPAGE_VAR_NEXTCLOUD_URL}}"
                  username: "{{HOMEPAGE_VAR_NEXTCLOUD_USERNAME}}"
                  password: "{{HOMEPAGE_VAR_NEXTCLOUD_PASSWORD}}"

      - Other:
          - GitLab:
              icon: gitlab.svg
              href: https://gitlab.com
              description: source code
          - GitHub:
              icon: github.svg
              href: https://github.com
              description: source code
          - Shlink:
              icon: https://shlink.io/images/shlink-logo-blue.svg
              href: "{{HOMEPAGE_VAR_SHLINK_URL}}"
              description: dashboard
      ```

    </details>
    {::options parse_block_html='false' /}

    {::options parse_block_html='true' /}
    <details>
      <summary markdown='span'>Setting Configuration</summary>

      ```yaml
      ---
      # For configuration options and examples, please see:
      # https://gethomepage.dev/latest/configs/settings

      title: Joker Wrld Homepage

      background:
        image: https://cdnb.artstation.com/p/assets/images/images/060/534/953/medium/julia-gorokhova-sci-fi-alley-fin2.jpg?1678790506
        blur: sm # sm, md, xl... see https://tailwindcss.com/docs/backdrop-blur
        saturate: 100 # 0, 50, 100... see https://tailwindcss.com/docs/backdrop-saturate
        brightness: 50 # 0, 50, 75... see https://tailwindcss.com/docs/backdrop-brightness
        opacity: 100 # 0-100

      theme: dark
      color: slate

      # useEqualHeights: true

      layout:
        Hypervisors:
          header: true
          style: row
          columns: 4
        Containers:
          header: true
          style: row
          columns: 4
        DNS:
          header: true
          style: row
          columns: 4
        Network:
          header: true
          style: row
          columns: 4
        Storage:
          header: true
          style: row
          columns: 4
        Media:
          header: true
          style: row
          columns: 4
        Other:
          header: true
          style: row
          columns: 4

      providers:
        openweathermap: openweathermapapikey
        weatherapi: weatherapiapikey
      ```

    </details>
    {::options parse_block_html='false' /}

    {::options parse_block_html='true' /}
    <details>
      <summary markdown='span'>Widgets Configuration</summary>

      ```yaml
      ---
      # For configuration options and examples, please see:
      # https://gethomepage.dev/latest/configs/service-widgets

      - resources:
          cpu: true
          memory: true
          disk: /

      - datetime:
          text_size: xl
          format:
            timeStyle: short
      ```

    </details>
    {::options parse_block_html='false' /}


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

Result:

![Homepage Dashboard](/assets/img/2024/posts/homepage-dashboard.webp)

