---
layout: post
title: 'Terraform: CLOUD PROJECT BOOTCAMP'
image:
  path: "/assets/img/2023/thumbs/terraform-bootcamp.webp"
categories:
- Infrastructure as Code (IaC)
- Content Delivery Network (CDN)
- Networking
- Project
tags:
- Cloudflare
- Git
- Linux
- AWS
- Terraform
date: 2023-12-25 17:52 +0200
---
## Why to use Terraform as IAC

Explore a comprehensive article on the topic: [Why we use Terraform and not Chef, Puppet, Ansible, Pulumi, or CloudFormation](https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c#.63ls7fpkq){: target="_blank"}.

Choosing the right Infrastructure as Code (IAC) tool is a critical decision for organizations looking to efficiently manage and scale their infrastructure. While there are various tools available, including Pulumi, Ansible, Chef, and Puppet, Terraform stands out for several compelling reasons:

1. **Declarative Syntax:**
   - Terraform utilizes a declarative syntax, allowing users to define the desired end state of their infrastructure. This makes it easy to understand and maintain configurations without specifying explicit step-by-step procedures.

2. **Multi-Cloud Support:**
   - Terraform is cloud-agnostic, providing support for multiple cloud providers such as AWS, Azure, Google Cloud, and more. This flexibility enables organizations to adopt a multi-cloud strategy seamlessly.

3. **Immutable Infrastructure:**
   - Terraform promotes the concept of immutable infrastructure, where infrastructure components are treated as disposable entities. This approach ensures consistency and repeatability in deployments, reducing the risk of configuration drift.

4. **Resource Graph:**
   - Terraform's resource graph allows for efficient dependency resolution. It understands the relationships between resources, optimizing the order of provisioning and avoiding unnecessary delays.

5. **Large and Active Community:**
   - Terraform boasts a large and vibrant community of users and contributors. This means extensive documentation, a plethora of modules, and a wealth of knowledge-sharing, making it easier to find solutions and best practices.

6. **Modular Architecture:**
   - Terraform's modular architecture enables the creation of reusable and shareable modules. This promotes consistency across projects, accelerates development, and simplifies collaboration among teams.

7. **Built-In State Management:**
   - Terraform includes a built-in state management system, which tracks the current state of the infrastructure. This facilitates collaboration among team members and helps prevent conflicts in concurrent deployments.

8. **Ease of Adoption:**
   - Terraform's learning curve is often considered gentler compared to some other IAC tools. Its simple and expressive syntax, coupled with comprehensive documentation, makes it accessible to both beginners and experienced users.

9. **Extensive Provider Ecosystem:**
   - Terraform's extensive provider ecosystem covers a wide range of services and resources for various cloud providers, as well as on-premises infrastructure. This diversity ensures that users can model and manage almost any type of infrastructure.

10. **Community Modules and Registry:**
    - The Terraform Module Registry provides a centralized repository of community-contributed modules, allowing users to leverage pre-built solutions for common infrastructure patterns. This accelerates development and ensures adherence to best practices.

While other IAC tools may excel in specific use cases or cater to different preferences, Terraform's broad compatibility, ease of use, and strong community support make it a popular choice for organizations seeking a robust and flexible solution for managing their infrastructure.

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

### [Terraform Cloud Variables](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables){: target="_blank"}

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

![Architectural Diagram](/assets/img/2023/posts/terraform-bootcamp-architecture.webp)

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

#### Setup Custom Cloudflare Domain

Let's setup custom domain name instead of CloudFront's random one.

- **Add Cloudflare provider section**

  In order to use Cloudflare API we need to modify `providers.tf` file.

  ```terraform
  terraform {
    cloud {
      organization = "jokerwrld"

      workspaces {
        name = "terraform-bootcamp"
      }
    }

    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
      }

      cloudflare = {
        source = "cloudflare/cloudflare"
        version = "4.20.0"
      }
    }

    required_version = ">= 1.5.0"
  }

  # AWS provider block

  provider "aws" {
    region     = var.region
    # access_key = var.AWS_ACCESS_KEY_ID
    # secret_key = var.AWS_SECRET_ACCESS_KEY
  }

  provider "cloudflare" {
    api_token = var.cloudflare_api_token
  }
  ```
  {: file="providers.tf"}

  Also we need to create some variables for Cloudflare in Terraform Cloud.

  ![Cloudflare Creds](/assets/img/2023/posts/terraform-bootcamp-cloudflare-creds.webp)

- **Generate SSL Certificate**

  AWS Certificate Manager (ACM) resource helps with generating SSL Cert for our domain `jokerwrld.win` and subdomains.

  ```terraform
  # Use the AWS Certificate Manager to create an SSL cert for our domain.
  resource "aws_acm_certificate" "certificate" {
    domain_name       = "*.${var.root_domain_name}"
    validation_method = "DNS"

    subject_alternative_names = ["${var.root_domain_name}"]

    lifecycle {
      create_before_destroy = true
    }
  }
  ```

  For DNS validation, we need to add some records to our domain's DNS configuration.

  ```terraform
  # Create Validation Record on Cloudflare
  resource "cloudflare_record" "cloudflare_validation_record" {
    zone_id = var.cloudflare_zone_id
    name    = "${tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name}"
    value   = "${tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value}"
    type    = "CNAME"
    proxied = false

    depends_on = [ aws_acm_certificate.certificate ]
  }
  ```

- **Modify CloudFront Distribution**

  In order to be able to access our website through our custom domain, we need to modify some CloudFront distribution options like `origin_id`, `aliases`, `target_origin_id`.

  ```terraform
  # CloudFront
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

  resource "aws_cloudfront_distribution" "cloudfront_distribution" {
    origin {
      domain_name = aws_s3_bucket.bootcamp_bucket.bucket_regional_domain_name
      origin_id   = "${var.sub_domain_name}"

      origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
    }

    aliases = ["${var.sub_domain_name}"]
    enabled = true
    default_root_object = "index.html"

    default_cache_behavior {
      allowed_methods  = ["GET", "HEAD"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "${var.sub_domain_name}"

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
      acm_certificate_arn = "${aws_acm_certificate.certificate.arn}"
      ssl_support_method = "sni-only"
    }

    restrictions {
      geo_restriction {
        restriction_type = "none"
        locations        = []
      }
    }
  }
  ```

- **Update DNS Records**

  Once the CloudFront distribution is created, we can update our Cloudflare records to point to the Cloudfront domain.

  ```terraform
  resource "cloudflare_record" "cloudflare_record" {
    zone_id = var.cloudflare_zone_id
    name    = "barista"
    value   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    type    = "CNAME"
    proxied = true
  }
  ```

- **Access Website**

  Now, let's access or content using the custom domain e.g., `https://barista.jokerwrld.win`.

  ![Static Website on Custom DNS](/assets/img/2023/posts/terraform-bootcamp-static-website-custom-dns.webp)

### Creating Reusable Infrastructure /W Terraform Modules

Why we need Terraform modules? Well, with Terraform we can put our code inside of Terraform module and reuse that module in multiple places throughout your code. Instead of having the same code copied and pasted in the  staging and production environments.

More comprehensive guide you can check in great article - [How to create reusable infrastructure with Terraform modules](https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d){: target="_blank"}

#### Terraform module structure

> A Terraform module is very simple: any set of Terraform configuration files in a folder is a module.

Module structure can be as follows:

```console
| PROJECT_ROOT
├── modules/
│   ├── cdn/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── variables.tf
│   └── storage/
│       ├── static-website/
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       └── variables.tf
├── LICENSE
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── terraform.tfvars
└── variables.tf
```

#### Module Composition

When you create modules it's essential to have input parameters, so that your modules stay as flexible as possible.

- **Input Variables**

  Input variables as variables like in Root module represent the same mechanism and can be accessed as usual using `var.variable_name` syntax.

  For example, in our project we are using global variable `root_domain_name` let's see how this variable is declared:

  1. Declare the variable in the `PROJECT_ROOT`

      ```terraform
      variable "root_domain_name" {
        description = "Root Domain Name"
        type        = string
      }
      ```
      {: file="PROJECT_ROOT/variables.tf"}

  2. Set the variable in the `terraform.tfvars` file or Terraform Cloud as the `terraform`` variable

      ```terraform
      root_domain_name = "jokerwrld.win"
      ```
      {: file="PROJECT_ROOT/terraform.tfvars"}

  3. Pass the variable into the module using `main.tf` file in the `PROJECT_ROOT`. Preferred format is `VARIABLE_NAME =  var.VARIABLE_NAME`

      ```terraform
      module "storage" {
        source = "./modules/storage"

        region               = var.region
        root_domain_name     = var.root_domain_name

        ...
      }
      ```
      {: file="PROJECT_ROOT/main.tf"}

  4. Declare the variable in a `modules/module_name` folder in the `variables.tf` file

      ```terraform
      variable "root_domain_name" {
        description = "Root Domain Name"
        type        = string
      }
      ```
      {: file="PROJECT_ROOT/modules/storage/variables.tf"}

  5. Use the declared variable in the `main.tf` file in the module folder

      ```terraform
      # S3 static website bucket
      resource "aws_s3_bucket" "bootcamp_bucket" {
        bucket = var.root_domain_name
      }
      ```
      {: file="PROJECT_ROOT/modules/storage/main.tf"}


- **Output Variables**

  Additionally, there is a feature that allows you to utilize output variables from one module as input variables for another module.

  To access module output variables, use the following syntax:

  ```
  module.<MODULE_NAME>.<OUTPUT_NAME>
  ```

  For example, let's export `bootcamp_bucket_id` variable from `storage` module into `cdn` module:

  1. Create the output variable in the `PROJECT_ROOT/modules/storage/outputs.tf` file

      ```terraform
      output "bootcamp_bucket_id" {
        value       = aws_s3_bucket.bootcamp_bucket.id
        description = "AWS S3 Bucket ID"
      }
      ```
      {: file="PROJECT_ROOT/modules/storage/outputs.tf"}

  2. Set the variable in the `terraform.tfvars` file or Terraform Cloud as the `terraform`` variable

      ```terraform
      root_domain_name = "jokerwrld.win"
      ```
      {: file="PROJECT_ROOT/terraform.tfvars"}

  3. Pass the `bootcamp_bucket_id` output variable into the `cdn` module using `main.tf` file in the `PROJECT_ROOT`.

      Format is: `INPUT_VARIABLE_NAME =  module.<MODULE_NAME>.<OUTPUT_VARIABLE_NAME>`

      ```terraform
      module "cdn" {
        source = "./modules/cdn"

        region                      = var.region
        root_domain_name            = var.root_domain_name
        subdomain_name              = var.subdomain_name
        cloudflare_api_token        = var.cloudflare_api_token
        cloudflare_zone_id          = var.cloudflare_zone_id
        bootcamp_bucket_id          = module.storage.bootcamp_bucket_id
        bucket_regional_domain_name = module.storage.bootcamp_bucket_bucket_regional_domain_name
      }
      ```
      {: file="PROJECT_ROOT/main.tf"}

  4. Declare the `bootcamp_bucket_id` as input variable in the `modules/cdn` folder in the `variables.tf` file

      ```terraform
      variable "bootcamp_bucket_id" {
        description = "AWS S3 Bucket ID"
        type        = string
      }
      ```
      {: file="PROJECT_ROOT/modules/cdn/variables.tf"}

  5. Use the exported output variable as the input variable in the `main.tf` file in the `cdn` module folder

      ```terraform
      resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
        comment = var.bootcamp_bucket_id
      }
      ```
      {: file="PROJECT_ROOT/modules/cdn/main.tf"}

By defining your IAC in modules, you increase scalability, reliability and your ability to build infrastructure quickly, because developers now are able to reuse entire pieces of proven, tested and documented infrastructure.

## Summary

Throughout our Terraform bootcamp, we explored the fundamentals and practical aspects of Infrastructure as Code (IAC) using Terraform. We initiated our journey by investigating why Terraform stands out as a preferred choice for IAC.

In the early stages, we grasped the foundational concept of Terraform's root module structure, gaining insights into its components and their contribution to the overall configuration. This knowledge set the stage for our subsequent exploration of Terraform variables, where we learned to declare, utilize, and manage variables within our Terraform configurations.

Our practical experience extended to the creation of IAC for a static website, a crucial exercise exposing us to the configuration settings necessary for efficiently hosting static content. Expanding our deployment capabilities, we delved into Terraform backends, comprehending their role in storing Terraform state and streamlining collaboration.

Our journey then transitioned to real-world applications with the setup of a static website hosted on Amazon S3. We navigated the intricacies of configuring the S3 bucket for website hosting and effectively linking our content. To optimize performance further, we explored the integration of Amazon CloudFront as a content delivery network (CDN) to enhance the website's reach and accessibility.

A pivotal point in our bootcamp involved the exploration of custom domain setup using Cloudflare, where we gained hands-on experience in configuring a custom domain and seamlessly integrating it into our Terraform configurations.

Understanding the principles behind modularizing our infrastructure code, we discovered the benefits of reusability across diverse projects. This modular approach not only enhances efficiency but also encourages best practices in code organization and maintainability.

As we conclude our bootcamp, we emerge with a comprehensive understanding of Terraform's capabilities. We have successfully built and optimized a static website, configured CloudFront for content delivery, and effectively managed our infrastructure as code. Importantly, the modularized infrastructure positions us for scalable and maintainable deployments across various projects, showcasing the robust power and flexibility inherent in Terraform as a top-tier IAC tool.

[GitHub Repository](https://github.com/jokerwrld999/terraform-beginner-bootcamp-2023.git){: target="_blank"}
