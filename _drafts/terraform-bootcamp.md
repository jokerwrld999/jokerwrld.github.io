---
layout: post
title: Terraform Bootcamp
image:
  path: "/assets/img/2023/thumbs/default.webp"
categories:
- Self-hosted
- Infrastructure as Code (IaC)
- Networking
- Project
tags:
- Git
- Linux
- Bash
- Ansible
- AWS
- Terraform
---



## Static Website

Download Css Template

```bash
wget https://www.tooplate.com/zip-templates/2137_barista_cafe.zip && unzip *.zip -d . && rm -rf *.zip
```

Install http-server

```bash
npm install http-server
```

Run Web Server

```bash
http-server -p 3000
```


## IAC

Architecture Diagram

### Terraform Backend

Load Backend into Terraform Cloud

```terraform
terraform {
  cloud {
    organization = "jokerwrld"

    workspaces {
      name = "terraform-bootcamp"
    }
  }
}
```

### S3 website hosting

- **Create & configure S3 bucket for website hosting:**

  ```terraform
  resource "aws_s3_bucket" "bootcamp_bucket" {
    bucket = "terraform-bootcamp-jokerwrld"
  }

  resource "aws_s3_bucket_website_configuration" "bootcamp_bucket_website" {
    bucket = aws_s3_bucket.bootcamp_bucket.id

    index_document {
      suffix = "index.html"
    }

    error_document {
      key = "index.html"
    }
  }

  resource "aws_s3_bucket_versioning" "bootcamp_bucket_versioning" {
    bucket = aws_s3_bucket.bootcamp_bucket.id

    versioning_configuration {
      status = "Enabled"
    }
  }
  ```

- **Setup S3 bucket ACLs:**

  ```terraform
  resource "aws_s3_bucket_ownership_controls" "bootcamp_bucket_ownership" {
    bucket = aws_s3_bucket.bootcamp_bucket.id
    rule {
      object_ownership = "BucketOwnerPreferred"
    }
  }

  resource "aws_s3_bucket_public_access_block" "bootcamp_bucket_access_block" {
    bucket = aws_s3_bucket.bootcamp_bucket.id

    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
  }

  resource "aws_s3_bucket_acl" "bootcamp_bucket_acl" {
    depends_on = [
      aws_s3_bucket_ownership_controls.bootcamp_bucket_ownership,
      aws_s3_bucket_public_access_block.bootcamp_bucket_access_block,
    ]

    bucket = aws_s3_bucket.bootcamp_bucket.id
    acl    = "public-read"
  }

  # S3 bucket policy

  resource "aws_s3_bucket_policy" "bootcamp_bucket_policy" {
    bucket = aws_s3_bucket.bootcamp_bucket.id

    policy = <<POLICY
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "PublicReadGetObject",
              "Effect": "Allow",
              "Principal": "*",
              "Action": "s3:GetObject",
              "Resource": "arn:aws:s3:::${aws_s3_bucket.bootcamp_bucket.bucket}/*"
          }
      ]
  }
  POLICY
  }
  ```

- **Upload website content:**

  In this step to upload website content we are going to use `template_files` module so that we can infer the content type and a few other attributes of a file which is important for website hosting on S3

  ```terraform
  module "template_files" {
    source = "hashicorp/dir/template"

    base_dir = "${path.module}/static-website"
  }

  resource "aws_s3_object" "provision_source_files" {
    for_each = module.template_files.files

    bucket = aws_s3_bucket.bootcamp_bucket.id
    key          = each.key
    content_type = each.value.content_type

    source       = each.value.source_path
    content = each.value.content
  }
  ```

- **Access the S3 static website:**

  For convenient website access added `output` with url

  ```terraform
  output "website_url" {
    value = "http://${aws_s3_bucket.bootcamp_bucket.bucket}.s3-website.${var.region}.amazonaws.com"
  }
  ```

  You can run the following command in your terminal to view the URL:

  ```bash
  terraform output website_url
  ```

  Finally, now you will be able to access our static website which is hosted on an AWS S3 bucket using Terraform.

  ![Static Website](/assets/img/2023/posts/terraform-bootcamp-website.webp)


### Cloudfront

In this section we will be using CloudFront to serve content from S3 bucket as origin.

Create Distribution

Configure Origin Access

Configure S3 Bucket Policy

