---
layout: post
title: test-tabs
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


### First tabs

{% tabs log %}

{% tab log php %}
```php
var_dump('hello');
```
{% endtab %}

{% tab log js %}
```javascript
console.log('hello');
```
{% endtab %}

{% tab log ruby %}
```javascript
pputs 'hello'
```
{% endtab %}

{% endtabs %}

### Second tabs

{% tabs data-struct %}

{% tab data-struct yaml %}
```yaml
hello:
  - 'whatsup'
  - 'hi'
```
{% endtab %}

{% tab data-struct json %}
```json
{
    "hello": ["whatsup", "hi"]
}
```
{% endtab %}

{% endtabs %}
