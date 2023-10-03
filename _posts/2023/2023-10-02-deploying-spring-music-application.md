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
published: false
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

4. **Configuring Nginx Reverse Proxy and Adding Self-Signed Certificates**
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
    

## Setting up Nginx Reverse Proxy

A reverse proxy is a server that sits in front of your web servers and forwards client requests to those servers. It acts as an intermediary for requests from clients, forwarding them to the appropriate server and then returning the server's response to the clients.

### Setup Nginx Reverse Proxy

To set up Nginx as a reverse proxy, follow this guide: [How To Configure Nginx as a Reverse Proxy on Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-configure-nginx-as-a-reverse-proxy-on-ubuntu-22-04){:target="_blank"}

#### Nginx Configuration File: /etc/nginx/sites-available/spring-music

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

In the provided Nginx configuration, we have the following key elements explained:

- **listen**: Specifies the IP address and port for Nginx to listen on.

- **server_name**: Defines the domain name for which this server block applies.

- **location**: Configures how Nginx should handle requests for the specified location.

- **proxy_pass**: Passes the client request to the specified backend server.

- **include proxy_params**: Includes common proxy parameters.

These elements play a crucial role in configuring Nginx as a reverse proxy, allowing it to effectively route and manage incoming requests.

## Create Self-Signed Certificates

To create a self-signed SSL certificate for Nginx, follow this guide: [How To Create a Self-Signed SSL Certificate for Nginx in Ubuntu 22.04](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-22-04#step-2-configuring-nginx-to-use-ssl){:target="_blank"}

#### Nginx Configuration File: /etc/nginx/sites-available/spring-music

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

In this configuration:

- **upstream**: Defines a basic load balancer, distributing requests across the servers defined within it. This is a valuable feature for managing traffic effectively. It's especially useful in scenarios where you have multiple backend servers and want to distribute the load evenly or use them in a failover configuration.

- **server**: Configures Nginx to listen on specified ports and handle requests accordingly.

- **listen**: Specifies the ports to listen on and enable SSL.

- **include**: Pulls in configurations from external files for SSL settings.

## Automation Scripts

### Startup Script:

```bash
#!/bin/bash

# Start the Spring Music application on port 8090
java -jar -Dserver.port=8090 -Dspring.profiles.active=mongodb ../build/libs/spring-music-1.0.jar & echo $! > ./pid1.file &

# Start another instance of the Spring Music application on port 8091
java -jar -Dserver.port=8091 -Dspring.profiles.active=mongodb ../build/libs/spring-music-1.0.jar & echo $! > ./pid2.file &
```

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

These scripts automate the startup and shutdown processes for the Spring Music application.

## CI/CD