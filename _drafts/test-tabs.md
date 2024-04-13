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

This Jekyll plugin provides tags used to add tabs in your content. It is heavily inspired from https://github.com/clustergarage/jekyll-code-tabs.

It works with multiple tab panels on the same page.
It does not require a specific javascript framework.
Additionally, you can:

Sync tabs with similar labels.
Have a specific tab automatically opened on page load.
Add a "copy to clipboard" button for tabs that contain code.

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
