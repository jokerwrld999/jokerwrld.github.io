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

## Terraform Root Module Structure

[Terraform Root Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure){:target="_blank"}

We organize our root module as follows:

```
PROJECT_ROOT
│
├── main.tf                 # everything else.
├── variables.tf            # stores the structure of input variables
├── terraform.tfvars        # the data of variables we want to load into our terraform project
├── providers.tf            # defined required providers and their configuration
├── outputs.tf              # stores our outputs
└── README.md               # required for root modules
```

## Terraform Variables

### [Terraform Cloud Variables](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables){:target="_blank"}

In Terraform Cloud we can set two kind of variables:

  - **Environment Variables:** Variables that can store provider credentials and other data that Terraform Cloud `export`s to populate into shell.

  - **Terraform Variables:**  Refer to [input variables](https://developer.hashicorp.com/terraform/language/values/variables){:target="_blank"} that define parameters without hardcoding them into the configuration.

## Static Website

[Free HTML Templates](https://www.tooplate.com/){:target="_blank"}

- Downloading CSS Template:

  ```bash
  wget https://www.tooplate.com/zip-templates/2137_barista_cafe.zip && unzip *.zip -d . && rm -rf *.zip
  ```

### Deploying Local HTTP Server

- Installing http-server:

  ```bash
  npm install http-server
  ```

- Running Web Server:

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


### CloudFront

AWS CloudFront is a Content Delivery Network (CDN) service that accelerates the delivery of your web content, including images, videos, scripts, and other static assets, to users around the world. It enhances the performance, reliability, and scalability of your web applications.

In this section we will be using CloudFront to serve content from S3 bucket as origin.

- **Define CloudFront Origin Access Control (OAC) & Origin Access Identity (OAI):**

  Origin Access Control (OAC) in AWS CloudFront allows you to control access to your origin content based on geographical locations and signed URLs or cookies. It provides additional security and access restrictions for your CloudFront distribution.

  Origin Access Identity (OAI) is a feature in AWS CloudFront that allows you to restrict access to your Amazon S3 origin. It acts as a virtual user to grant CloudFront permission to access your private S3 content. Instead of allowing public access, you restrict access to the S3 bucket only through the CloudFront distribution.

  ```terraform
  resource "aws_cloudfront_origin_access_control" "cloudfront_s3_oac" {
    name                              = "CloudFront S3 OAC"
    description                       = "Cloud Front S3 OAC"
    origin_access_control_origin_type = "s3"
    signing_behavior                  = "always"
    signing_protocol                  = "sigv4"
  }

  resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
    comment = "${aws_s3_bucket.bootcamp_bucket.id}"
  }
  ```

- **Create CloudFront Distribution:**

  A CloudFront distribution is the main configuration entity. It specifies the origin (source) of your content, cache behaviors, TTL (Time To Live) settings, and more.

  ```terraform
  resource "aws_cloudfront_distribution" "cloudfront_distribution" {

    origin {
      domain_name = aws_s3_bucket.bootcamp_bucket.bucket_regional_domain_name
      origin_id   = aws_s3_bucket.bootcamp_bucket.id

      origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
    }

    enabled = true
    default_root_object = "index.html"

    default_cache_behavior {
      allowed_methods  = ["GET", "HEAD"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = aws_s3_bucket.bootcamp_bucket.id

      forwarded_values {
        query_string = false

        cookies {
          forward = "none"
        }
      }

      viewer_protocol_policy = "allow-all"
      min_ttl                = 0
      default_ttl            = 3600
      max_ttl                = 86400
    }

    viewer_certificate {
      cloudfront_default_certificate = true
    }

    restrictions {
      geo_restriction {
        restriction_type = "none"
        locations        = []
      }
    }
  }
  ```

- **Configure S3 Bucket Policy:**

  Now in this step we need to reconfigure our S3 Bucket to prevent unintended public access and allow read-only access to objects in the S3 bucket for the AWS CloudFront service. It ensures that only the specified CloudFront distribution can access the S3 bucket's objects.

  ```terraform
  # S3 bucket ACL access

  resource "aws_s3_bucket_ownership_controls" "bootcamp_bucket_ownership" {
    bucket = aws_s3_bucket.bootcamp_bucket.id
    rule {
      object_ownership = "BucketOwnerPreferred"
    }
  }

  resource "aws_s3_bucket_public_access_block" "bootcamp_bucket_access_block" {
    bucket = aws_s3_bucket.bootcamp_bucket.id

    block_public_acls       = true
    block_public_policy     = true
  }

  # S3 bucket policy

  resource "aws_s3_bucket_policy" "bootcamp_bucket_policy" {
    bucket = aws_s3_bucket.bootcamp_bucket.id

    policy = <<POLICY
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "AllowCloudFrontServicePrincipalReadOnly",
              "Effect": "Allow",
              "Principal": {
                  "Service": "cloudfront.amazonaws.com"
              },
              "Action": "s3:GetObject",
              "Resource": "arn:aws:s3:::${aws_s3_bucket.bootcamp_bucket.bucket}/*",
              "Condition": {
                  "StringEquals": {
                      "AWS:SourceArn": "${aws_cloudfront_distribution.cloudfront_distribution.arn}"
                  }
              }
          }
      ]
  }
  POLICY
  }
  ```

- **Accessing Website:**

  By visiting CloudFront URL, we can access our static website that using HTTPS protocol which helps with encryption of the date in transit.

  ![CloudFront Static Website](/assets/img/2023/posts/terraform-bootcamp-cloudfront-website.webp)

<!---
TODO: Custom Domain /W Cloudflare provider
>