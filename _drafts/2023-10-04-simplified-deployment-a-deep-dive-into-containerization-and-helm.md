---
layout: post
title: 'Simplified Deployment: A Deep Dive into Containerization and Helm'
date: 2023-10-04 11:21 +0300
image:
  path: "/assets/img/2023/thumbs/default.webp"
categories:
- Self-hosted
- Automation
- Configuration Management
- Infrastructure as Code (IaC)
- Templating
- Networking
- Project
tags:
- Git
- Linux
- Bash
- Nginx
- Docker
- Kubernetes
- Helm
- Python

---

## Introduction

In this post, we embark on a journey through the fundamental concepts of containerization and the practical use of Helm charts. Containerization provides a streamlined approach to packaging, distributing, and deploying software, while Helm simplifies the management of complex applications on Kubernetes.

Let's navigate through the essence of containerization and Helm charts, understanding how they contribute to modern software development and deployment. Join us as we unravel the mechanics of these essential tools.

## Dockerizing the Application

Package the FastAPI application into a Docker container for portability and easier deployment.

This Dockerfile uses a multi-stage build process to optimize the Docker image size for the 'hello-world' FastAPI application.

```Dockerfile
FROM python:slim-bullseye AS builder

WORKDIR /app
COPY poetry.lock pyproject.toml main.py .env gunicorn.sh ./

RUN python -m pip install --no-cache-dir poetry==1.5.1 \
    && poetry config virtualenvs.in-project true \
    && poetry install --no-interaction --no-ansi || true \
    && poetry shell || true

FROM alpine:latest AS base

RUN  apk update \
    && apk upgrade \
    && apk add ca-certificates \
    && update-ca-certificates \
    && echo http://dl-cdn.alpinelinux.org/alpine/v3.6/main >> /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/v3.6/community >> /etc/apk/repositories \
    && apk add --update coreutils && rm -rf /var/cache/apk/*   \
    && apk add --update python3 py3-pip \
    && apk add --no-cache nss \
    && rm -rf /var/cache/apk/*


FROM base

WORKDIR /web

ENV ENVIRONMENT=default
ENV ENVIRONMENT_FROM_SECRET=secret_default

RUN python -m pip install --no-cache-dir fastapi gunicorn uvicorn

COPY --from=builder /app ./
COPY app ./app

CMD ["./gunicorn.sh"]
```
{: file="Dockerfile"}

### Build Process:

1. **Builder Stage**:
   - Utilizes the `python:slim-bullseye` image.
   - Sets the working directory to `/app`.
   - Copies essential files like poetry configuration, application files, and the gunicorn script.
   - Installs dependencies via Poetry and creates a virtual environment.

2. **Base Stage**:
   - Based on the `alpine:latest` image, a lightweight Linux distribution.
   - Installs necessary packages including Python and pip.
   - Sets the working directory to `/web`.
   - Defines environment variables for the application.

3. **Dependency Installation**:
   - Installs required Python packages using pip.

4. **Application Setup**:
   - Copies files from the builder stage to the final image, including the FastAPI application code.

5. **CMD Directive**:
   - Specifies the command to start the application using `gunicorn.sh`.

The resulting Docker image is optimized, effectively reducing the image size while maintaining application functionality.

## Helm and Its Features

[Helm](https://helm.sh/){: target="_blank"} is a widely used package manager for Kubernetes, designed to simplify and automate the deployment, scaling, and management of applications. It provides an efficient way to define, install, and upgrade even complex Kubernetes applications.

### Key Features of Helm:

1. **Package Management**:
   - Helm packages applications as "charts," making it easy to share and install applications on Kubernetes clusters.

2. **Templating and Parameterization**:
   - Helm allows users to use templates to define Kubernetes manifests, enabling parameterization and customization of these manifests during installation.

3. **Reusability**:
   - Helm charts promote the reuse of predefined configurations and deployment strategies across multiple applications, streamlining the development process.

4. **Dependency Management**:
   - Helm handles dependencies between Kubernetes resources, ensuring the correct order of installation and removal for complex applications.

5. **Rollbacks and Upgrades**:
   - Helm supports rollbacks to previous versions and facilitates seamless upgrades of applications to newer versions, improving the overall deployment process.

6. **Community Contributions**:
   - Helm has a thriving community contributing to a vast collection of prebuilt charts, covering a wide array of applications and services.

With these features, Helm significantly simplifies Kubernetes application management, making it a vital tool in the Kubernetes ecosystem.


## Minikube installation
Installation: https://minikube.sigs.k8s.io/docs/start/
```bash
minikube config set driver docker
minikube start // stop
minikube status
```

## Kubectl Insallation/Configuration
Installation: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

```bash
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

cat ~/.kube/config  // kubectl config view
alias k='kubectl'
```

## Helm Insallation/Configuration
Installation: https://helm.sh/docs/intro/install/
Cheat Sheet: https://helm.sh/docs/intro/cheatsheet/

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

## Plugins Installation
```bash
helm plugin install https://github.com/databus23/helm-diff
helm plugin install https://github.com/aslafy-z/helm-git
helm plugin install https://github.com/jkroepke/helm-secrets
```

## Secrets Encryption
```bash
helm secrets encrypt prod/secrets.yaml
```
## Namespace Creation
```bash
kubectl create namespace dev
kubectl create namespace stage
kubectl create namespace prod
```

## Github Registry Login
```bash
export CR_PAT=

kubectl create secret docker-registry ghcr-login-secret --docker-server=https://ghcr.io --docker-username=jokerwrld999 --docker-password=$CR_PAT --docker-email=example@gmail.com -n dev
kubectl create secret docker-registry ghcr-login-secret --docker-server=https://ghcr.io --docker-username=jokerwrld999 --docker-password=$CR_PAT --docker-email=example@gmail.com -n stage
kubectl create secret docker-registry ghcr-login-secret --docker-server=https://ghcr.io --docker-username=jokerwrld999 --docker-password=$CR_PAT --docker-email=example@gmail.com -n prod
```

## Helmfile Deployment
Installation: https://github.com/helmfile/helmfile/releases

### Development Environment
```bash
helmfile --file helmfile.yaml -e dev apply --interactive
helmfile --file helmfile.yaml -e dev destroy
```

### Staging Environment
```bash
helmfile --file helmfile.yaml -e stage apply --interactive
helmfile --file helmfile.yaml -e stage destroy
```

### Production Environment
```bash
helmfile --file helmfile.yaml -e prod apply --interactive
helmfile --file helmfile.yaml -e prod destroy
```

## Debug/Healthcheck
Service_IP/openapi.json
Service_IP/secret
Service_IP/healthcheck

## Access Commands
```bash
curl -H "Host: dev.jokerwrld.com" http://$(minikube ip)/
curl -H "Host: stage.jokerwrld.com" -k https://$(minikube ip)/
curl -H "Host: prod.jokerwrld.com" -k https://$(minikube ip)/
```