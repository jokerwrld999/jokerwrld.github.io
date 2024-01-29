---
layout: post
title: Kubernetes at Home
image:
  path: "/assets/img/2024/thumbs/default.webp"
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

## **Introduction to Kubernetes at Home**

In the ever-evolving landscape of modern infrastructure management, Kubernetes has emerged as a pivotal tool, transforming the way applications are deployed, scaled, and managed. In this documentation, we embark on a journey to explore the realms of Kubernetes at home, demystifying the terminology, understanding variations like k8s and k3s, and delving into alternatives for deploying and orchestrating applications.

### **Kubernetes Unveiled**

[Kubernetes (k8s)](https://kubernetes.io/){:target='_blank'} is an open-source container orchestration platform designed to automate the deployment, scaling, and management of containerized applications. Originally developed by Google, Kubernetes has become a cornerstone in the world of cloud-native technologies, offering a declarative approach to application deployment and seamless scaling.

### **Distinguishing k8s and k3s**

**k8s (Kubernetes):**

  - The widely recognized abbreviation for Kubernetes, representing the eight letters between 'k' and 's' in the word.

  - Ideal for larger-scale deployments, often in enterprise or cloud environments.

**k3s:**

  - A lightweight distribution of Kubernetes, tailored for resource-constrained environments.

  - Designed for simplicity, k3s is well-suited for edge computing, IoT devices, or home labs.

### **Exploring Alternatives**

**Self-Hosting:**

  - Opting for a self-hosted Kubernetes deployment allows enthusiasts to have full control over their clusters.

  - Ideal for learning and experimentation, it provides insights into the intricacies of cluster management.

**Cloud Provider Solutions:**

  - Leveraging cloud providers' managed Kubernetes services, such as Google Kubernetes Engine (GKE), Amazon EKS, or Azure Kubernetes Service (AKS), offers convenience in setup and maintenance.

  - Suitable for users who prioritize ease of use and abstraction of underlying infrastructure complexities.

## **Introduction to Vagrant: A Local Playground for DevOps Enthusiasts**

In the realm of DevOps and infrastructure as code (IaC), Vagrant stands out as a versatile tool, empowering developers and system administrators to create and manage reproducible virtual environments. This section of the documentation delves into the essence of Vagrant, why it's a crucial tool in the DevOps toolkit, and the benefits it brings to local testing before venturing into production.

### **Vagrant Unveiled**

**What is Vagrant?**

[Vagrant](https://www.vagrantup.com/){:target='_blank'} is an open-source tool that facilitates the creation, provisioning, and management of portable development environments. It allows users to define virtual machines or containers using a declarative configuration file, enabling consistent and shareable development environments across diverse teams.

### **Why Vagrant for Local Testing**

**1. Reproducible Environments**

  - Vagrant enables the definition of environments using code, ensuring that setups are consistent across different machines and platforms.

**2. Isolation and Sandboxing**

  - Virtual environments created by Vagrant provide a sandboxed space for testing without impacting the host system.

**3. Compatibility Assurance:**

  - Local testing with Vagrant helps identify and address compatibility issues early in the development process.

### **Variations in Vagrant Usage**

**Single-Machine vs. Multi-Machine:**

  - Vagrant supports both single-machine and multi-machine configurations, accommodating diverse project requirements.

**Providers:**

  - Vagrant is provider-agnostic, supporting providers like VirtualBox, VMware, and Docker. Users can choose the provider that best fits their use case.

### **Exploring Alternatives**

**Docker Compose:**

  - For containerized applications, Docker Compose offers a simplified way to define and manage multi-container applications.

**Local Development Servers:**

  - Some developers prefer using local development servers like XAMPP or MAMP for specific application stacks.

### **Best Practices with Vagrant**

**1. Version Control:**

  - Include Vagrant configuration files in version control systems for seamless collaboration.

**2. Base Boxes:**

  - Utilize pre-configured base boxes to jumpstart development environments.

**3. Provisioning:**

  - Leverage provisioning tools like Ansible, Chef, or Puppet for automated setup and configuration.

### **Vagrant Installation**

Follow [Official Installation Instruction](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant#Linux){:target='_blank'} to get Vagrant up & running.

Check the Vagrant version:

```bash
vagrant -v
```

### Architecture

## **k3s Architecture**

![k3s Architecture](/assets/img/2024/posts/k3s-on-prem-k3s-architecture.webp)

The components of k3s are very similar to traditional kubernetes(k8s).

First is a k3s Server which is host running the control plane and the datastore.

Next is a k3s Agent this is a host that is running, but without control plane and datastore, traditionally where the workloads would go.

Each of these are running in a single process on a respective hosts.

### **Single-Server**

![k3s Single-Server Architecture](/assets/img/2024/posts/k3s-on-prem-k3s-single-server-architecture.webp)

A single-server setup will use a single-server node with embedded SQLLite database. Each agent node will be registered with a single-server node and all changes a user will do will be done through the Server Node.

### **High Availability with etcd**

![k3s HA /W etcd](/assets/img/2024/posts/k3s-on-prem-k3s-ha-with-etcd.webp)

With High Availability with etcd end users will connect to load balancer that will load balance traffic across all server nodes. The database store and etcd will be embedded into each of the Server Nodes and those Server Nodes will be able to communicate with respective agent nodes. External traffic will come in through a load balancer to each Agent Node and their respective workloads.

### **High Availability with External Database**

![k3s HA /W External DB](/assets/img/2024/posts/k3s-on-prem-k3s-ha-with-external-db.webp)

High availability with an external database works pretty similarly to how high availability works with an embedded database, but this instead of just having an external database.

## Ansible

## Rancher

## Longhorn Storage