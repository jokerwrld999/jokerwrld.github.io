---
layout: post
title: Personal Docs Website /W Jekyll
date: 2023-09-25 14:57 +0300
image:
  path: /assets/img/thumbs/2023-thumbs/default.jpg
categories:
- homelab
- linux
- hardware
tags:
- servers
- ubuntu
published: true
---

## Introduction to Jekyll

[Jekyll](https://jekyllrb.com/) is a popular static site generator that simplifies the process of building and maintaining websites. It's designed for creating simple, fast, and secure websites or blogs with minimal setup and maintenance.

### Key Features

1. **Static Site Generation:**
   Jekyll is a static site generator, meaning it generates plain HTML files during the build process. This results in a fast, lightweight, and easy-to-host website.

2. **Markdown Support:**
   Jekyll allows content creation using Markdown, a simple plain-text formatting syntax. Markdown files are transformed into HTML during the build process.

3. **Liquid Templating Engine:**
   Jekyll uses the Liquid templating engine, enabling dynamic content and layouts without relying on a server or a database. It provides a flexible way to manage and display data.

4. **Customization and Theming:**
   Developers can create custom themes or use pre-built themes to style their websites. Jekyll supports CSS, HTML, and JavaScript, allowing complete customization.

5. **GitHub Pages Integration:**
   Jekyll is well-integrated with GitHub Pages, making it easy to deploy and host your website directly from a GitHub repository.

6. **Content Organization:**
   Content in Jekyll is organized into collections, which can be easily categorized, tagged, and structured according to your needs.

7. **Plugin System:**
   Jekyll offers a plugin system to extend functionality. Users can create and utilize plugins to add features or automate tasks.

8. **SEO-Friendly:**
   Jekyll websites tend to be highly optimized for search engines, providing clean HTML and excellent performance.

### Use Cases

- **Personal Blogs:** Jekyll is commonly used for creating personal blogs due to its ease of use and quick setup.

- **Documentation Websites:** Jekyll is suitable for creating documentation sites, making it easy to organize and present information effectively.

- **Project Websites:** It's ideal for creating project websites or landing pages, providing a professional and straightforward way to showcase projects.

Jekyll is a valuable tool for anyone looking to build a static website or blog efficiently and focus on content creation rather than complex configurations.

## Install Dependencies

### Ubuntu

```shell
sudo apt update
sudo apt install -y ruby-full build-essential zlib1g-dev git
```

To avoid installing RubyGems packages as the root user:

If you are using `bash` (usually the default for most)

```bash
echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

If you are using `zsh` (you know if you are)

```bash
echo '# Install Ruby Gems to ~/gems' >> ~/.zshrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.zshrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Arch

```shell
sudp pacman -Syu
sudo pacman -S ruby ruby-rdoc gcc make --noconfirm
```

To avoid installing RubyGems packages as the root user:

If you are using `bash` (usually the default for most)

```bash
echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

If you are using `zsh` (you know if you are)

```bash
echo '# Install Ruby Gems to ~/gems' >> ~/.zshrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.zshrc
echo 'export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Install Jekyll `bundler`

```bash
gem update --user-install
gem install jekyll bundle --user-install
```

## Creating a site based on Starter Template

Templates <https://pinglestudio.peopleforce.io/knowledge_base/articles/46782>

After selecting a Jekyll template, you can fork it and follow the setup instructions in the `README.md` file.

## Jekyll Commands

### Recommended Plugin For Extending Jekyll Commands

Jekyll Compose <https://github.com/jekyll/jekyll-compose>

Set default front matter for drafts and posts in `_config.yml` file in site root directory

```yml
jekyll_compose:
  default_front_matter:
    drafts:
      image:
        path: /assets/img/thumbs/2023-thumbs/default.jpg
      categories:
        - homelab
        - linux
        - hardware
      tags:
        - servers
        - ubuntu
    posts:
      image:
        path: /assets/img/thumbs/2023-thumbs/default.jpg
      categories:
        - homelab
        - linux
        - hardware
      tags:
        - servers
        - ubuntu
      published: false
```

#### Usage

Create your new post using:

```bash
bundle exec jekyll post "My New Post"
# or
bundle exec jekyll post "My New Post" --timestamp-format "%Y-%m-%d %H:%M:%S %z"
```

Covenient quick Bash `function` to create a post in a desired subdirectory

```bash
new_post() {
    if [ ! -d "_posts/$1" ]; then
        mkdir -p "_posts/$1"
    fi
    bundle exec jekyll post "$2" | grep -oP '_.*?\.md' | xargs basename | read filename
    mv "_posts/$filename" "_posts/$1/$filename"
}

new_post "<YOUR-SUBFOLDER>" "<POST-NAME>"
```

Serving your site

```bash
bundle exec jekyll s
```

Building your site in production mode

```bash
JEKYLL_ENV=production bundle exec jekyll b
```