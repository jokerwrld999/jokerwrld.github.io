---
layout: post
title: Deploying Spring Music Application
date: 2023-10-02 16:27 +0300
image:
  path: "/assets/img/2023/thumbs/default.webp"
categories:
  - Self-hosted
  - Automation
  - CI/CD
  - Configuration Management
  - Infrastructure as Code (IaC)
  - Networking
  - Project
tags:
  - Git
  - Linux
  - Bash
  - Nginx
  - Docker
  - Ansible
  - Jenkins
published: true
---

## Intoduction

In this post, we will walk through the Software Development Lifecycle (SDLC) of a Java Spring application. Our demonstration will be based on the popular Spring Music sample record album collection application, originally designed to showcase database services on Cloud Foundry and the Spring Framework.

However, instead of utilizing Cloud Foundry initially, we will begin by hosting the Spring Music application on a local on-premises server, providing insights into traditional deployment methods. Later in the guide, we will explore containerization using Docker, enabling a more flexible and versatile deployment approach.

### Overview of the SDLC Steps

1. **Local Development Environment Setup**
   - Preparing your local development environment is the initial step, ensuring you have all the necessary tools and configurations in place.

2. **Building the Spring Music Application**
   - We'll delve into the manual steps of building the Spring Music application on your local machine, utilizing essential build tools and frameworks.

3. **Running the Spring Music Application Locally**
   - Explore deploying the Spring Music app on a local on-premises server, providing insights into traditional deployment practices.

4. **Setting up Nginx Reverse Proxy and Adding Self-Signed Certificates**
   - Learn how to set up Nginx as a reverse proxy to forward requests to the Spring Music app, enhancing security and performance. Additionally, we'll cover adding self-signed SSL/TLS certificates to ensure secure communication.

5. **Creating a Docker Image**
   - Learn how to containerize the application by creating a Docker image, making it portable and easily deployable across various environments.

6. **Running the Application Locally via Docker**
   - Experience deploying the Spring Music app locally using Docker, providing a controlled environment for testing and development.

7. **Optional: Deploying on AWS**
   - Extend your deployment knowledge to the cloud by setting up the Spring Music app on Amazon Web Services (AWS), allowing for scalable and resilient deployments.

## Local Development Environment Setup

Begin by setting up your Ubuntu 22.04 server. Ensure you have a clean installation and SSH access to the server.

**Install Java and Tomcat**
- Follow this guide to install Java and Tomcat: [How to Install Tomcat 10 on Ubuntu 22.04](https://linuxize.com/post/how-to-install-tomcat-10-on-ubuntu-22-04/){:target="_blank"}

**Install Gradle**
- To install Gradle, use the following guide: [How to Install Gradle on Ubuntu 22.04](https://linuxhint.com/installing_gradle_ubuntu/){:target="_blank"}

**Install MongoDB**
- For MongoDB installation, follow this guide: [Install MongoDB Community Edition on Ubuntu](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/){:target="_blank"}

## Building the Spring Music Application

[Gradle](https://gradle.org/){:target="_blank"} is a powerful build automation tool that supports multiple programming languages and platforms. It uses a Groovy-based domain-specific language (DSL) to describe the build logic.

To build the Spring Music application, we'll utilize Gradle and its wrapper script, which ensures that you use a consistent version of Gradle across different environments.

### About Gradle

Gradle offers several advantages for building and managing projects:

- **Concise Build Scripts**: Gradle uses a Groovy-based DSL, making build scripts easy to read and write.

- **Dependency Management**: It handles dependencies and transitive dependencies seamlessly.

- **Plugin System**: You can extend Gradle's functionality using plugins, enabling a wide range of features.

- **Incremental Builds**: Gradle builds only the parts of the project that have changed since the last build, speeding up the build process.

### Build Command

Clone the Spring Music application's source code from the repository: [Spring Music GitHub Repository](https://github.com/jokerwrld999/spring-music){:target="_blank"}

To build the Spring Music application using Gradle, run the following command in the project directory:

```bash
./gradlew clean assemble
```

This command will clean the project, compile the source code, run tests, and package the application.

## Running the Spring Music Application Locally

To run the Spring Music application locally, you'll use the `java` command to execute the built JAR file with specific configurations.

1. Run the application on port 8090:
    ```bash
    java -jar -Dserver.port=8090 -Dspring.profiles.active=mongodb build/libs/spring-music-1.0.jar
    ```

    This command runs the application on port 8090. You can access the application by visiting `http://localhost:8090`.

2. Run another instance of the application on port 8091:
    ```bash
    java -jar -Dserver.port=8091 -Dspring.profiles.active=mongodb build/libs/spring-music-1.0.jar
    ```

    This command runs another instance of the application on port 8091. Access this instance using `http://localhost:8091`.

Feel free to adjust the port numbers as needed for your setup.

## Setting up Nginx Reverse Proxy and Adding Self-Signed Certificates

A reverse proxy is a server that sits in front of your web servers and forwards client requests to those servers. It acts as an intermediary for requests from clients, forwarding them to the appropriate server and then returning the server's response to the clients.

### Setup Nginx Reverse Proxy

To set up Nginx as a reverse proxy, follow this guide: [How To Configure Nginx as a Reverse Proxy on Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-configure-nginx-as-a-reverse-proxy-on-ubuntu-22-04){:target="_blank"}

When configuring a reverse proxy with Nginx, we typically organize our server block configurations using the `sites-available` and `sites-enabled` directories.

- **`sites-available`**: This directory holds individual configuration files for various server blocks (virtual hosts) that define how Nginx should handle requests for different websites or applications.

- **`sites-enabled`**: This directory contains symbolic links to configuration files from `sites-available`. Only the configuration files (server blocks) that are symlinked here are actively used by Nginx.

#### Workflow Overview:

1. **Create Configuration in `sites-available`**: Begin by creating a new configuration file (e.g., `example.com`) for your website or application in the `sites-available` directory.

2. **Enable the Configuration**: Create a symbolic link from the `sites-available` directory to the `sites-enabled` directory using a command like `ln -s`. This links the configuration to the enabled sites.

3. **Restart Nginx**: After enabling the site, restart Nginx for the changes to take effect using a command like `sudo systemctl restart nginx`.

By organizing configurations in this manner, it's easy to manage multiple sites or applications on a single Nginx server.

Here's an example of how you might enable a site:

```bash
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

### Add Nginx Configuration File

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name spring-music www.spring-music;

    location / {
        proxy_pass http://192.168.100.89:8080;
        include proxy_params;
    }
}
```
{: file="/etc/nginx/sites-available/spring-music" }

In the provided Nginx configuration, we have the following key elements explained:

- **listen**: Specifies the IP address and port for Nginx to listen on.

- **server_name**: Defines the domain name for which this server block applies.

- **location**: Configures how Nginx should handle requests for the specified location.

- **proxy_pass**: Passes the client request to the specified backend server.

- **include proxy_params**: Includes common proxy parameters.

These elements play a crucial role in configuring Nginx as a reverse proxy, allowing it to effectively route and manage incoming requests.

## Create Self-Signed Certificates

To create a self-signed SSL certificate for Nginx, follow this guide: [How To Create a Self-Signed SSL Certificate for Nginx in Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-22-04#step-2-configuring-nginx-to-use-ssl){:target="_blank"}

#### Modify Nginx Configuration

```nginx
upstream spring-music.com {
  server 192.168.100.89:8090;
  server 192.168.100.89:8091;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    include snippets/self-signed.conf;
    include snippets/ssl-params.conf;

    server_name spring-music.com www.spring-music.com;

    location / {
        proxy_pass http://spring-music.com;
        include proxy_params;
    }
}

server {
    listen 80;
    listen [::]:80;

    server_name spring-music.com www.spring-music.com;

    return 301 https://$server_name$request_uri;
}
```
{: file="/etc/nginx/sites-available/spring-music" }

In this configuration:

- **upstream**: Defines a basic load balancer, distributing requests across the servers defined within it. This is a valuable feature for managing traffic effectively. It's especially useful in scenarios where you have multiple backend servers and want to distribute the load evenly or use them in a failover configuration.

- **server**: Configures Nginx to listen on specified ports and handle requests accordingly.

- **listen**: Specifies the ports to listen on and enable SSL.

- **include**: Pulls in configurations from external files for SSL settings.

## Automation Scripts

In order to streamline the deployment and management of the Spring Music application, we utilize the following automation scripts.

### Startup Script:

```bash
#!/bin/bash

# Start the Spring Music application on port 8090
java -jar -Dserver.port=8090 -Dspring.profiles.active=mongodb ../build/libs/spring-music-1.0.jar & echo $! > ./pid1.file &

# Start another instance of the Spring Music application on port 8091
java -jar -Dserver.port=8091 -Dspring.profiles.active=mongodb ../build/libs/spring-music-1.0.jar & echo $! > ./pid2.file &
```
{: file="start.sh" }

### Shutdown Script:

```bash
#!/bin/bash

# Stop the Spring Music application running on port 8090
kill $(cat ./pid1.file)

# Stop the Spring Music application running on port 8091
kill $(cat ./pid2.file)

# Cleanup the PID files
rm ./pid1.file
rm ./pid2.file
```
{: file="shutdown.sh" }

## CI/CD with Jenkins

In this section, we'll walk through the setup and configuration for CI/CD using Jenkins.

### Deploy Jenkins Container

To deploy Jenkins as a container, follow the instructions in the linked guide: [Homelab Containers](https://github.com/jokerwrld999/homelab-containers){:target="_blank"}

### Setup Jenkins Agent/Slave

Follow this instruction to setup Jenkins Slave: [How To Setup Jenkins Agent/Slave Using SSH](https://devopscube.com/setup-slaves-on-jenkins-2/){: target="_blank"}

### Receive Github Webhooks on Jenkins without Public IP

To receive Github webhooks on Jenkins without a public IP, use the following command:

```bash
relay forward --bucket github-jenkins http://localhost:8080/github-webhook/
```

More details can be found in the guide: [Receive Github webhooks on Jenkins without public IP — Web Relay](https://webhookrelay.com/blog/2017/11/23/github-jenkins-guide/){: target="_blank"}

### Create systemd Service for Running the Application in the Background

To run the Spring Music application as a background service using systemd, follow these steps:

1. Create a service file named `spring-music.service`:

```ini
[Unit]
Description=Spring-music Application
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/java -jar -Dserver.port=8090 -Dspring.profiles.active=mongodb /home/jokerwrld/spring-music-app/spring-music-1.0.jar
User=jokerwrld
Restart=always

# Note: Sending a SIGINT (as in CTRL-C) results in an exit code of 130 (which is normal)
KillMode=process
KillSignal=SIGINT
SuccessExitStatus=130
TimeoutStopSec=10

StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```
{: file="/etc/systemd/system/spring-music.service"}

2. Move the file to `/etc/systemd/system/`:

    ```bash
    sudo mv spring-music.service /etc/systemd/system/
    ```

3. Reload the systemd manager configuration:

    ```bash
    sudo systemctl daemon-reload
    ```

5. Start and enable the service to start on boot:

    ```bash
    sudo systemctl enable --now spring-music.service
    ```

Now, the Spring Music application will run as a background service.

### Test Web UI

To test the Spring Music application's web UI, use the following script:

```bash
#!/bin/bash

RESPONSE=$(wget --server-response https://spring-music.com/ --no-check-certificate 2>&1 | awk '/HTTP\// {print $2}')

if [ $RESPONSE = 200 ]; then
    echo "Spring-music Application is UP"
else
    echo "Got error $RESPONSE. Spring-music Application is DOWN :("
    exit 1
fi
```
{: file="test.sh"}

### Combine it in Jenkinsfile

To define the entire pipeline in a Jenkinsfile, follow these steps:

1. Create a file named `Jenkinsfile` in your project repository.

2. Add the following content to the `Jenkinsfile`:

```groovy
pipeline {
    agent any
    stages {
        stage('Checkout Project') {
            steps {
                git branch: 'master',
                credentialsId: 'github_cred',
                url: 'git@github.com:jokerwrld999/spring-music.git'
            }
        }
        stage('Build') {
            steps {
                echo "Building.."
                sh './gradlew clean assemble'
            }
        }
        stage('Deploy') {
            steps {
                echo "Deploying.."
                sh '''
                export SRC=$(pwd)
                ./custom-configs/deployment/deploy.sh
                sleep 10
                '''
            }
        }
        stage('Test') {
            steps {
                echo "Testing.."
                sh './custom-configs/test/test.sh'
            }
        }
    }
}
```
{: file="Jenkinsfile"}