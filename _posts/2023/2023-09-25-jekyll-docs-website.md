---
layout: post
title: Personal Docs Website /W Jekyll
date: 2023-09-25 14:57 +0300
image:
  path: /assets/img/2023/thumbs/jekyll.webp
categories:
- Self-hosted
- CI/CD
- Project
tags:
- Linux
- Git
- Jekyll
- Ruby
- Bash
- Markdown
published: true
---

## Introduction to Jekyll

[Jekyll](https://jekyllrb.com/){:target="_blank"} is a popular static site generator that simplifies the process of building and maintaining websites. It's designed for creating simple, fast, and secure websites or blogs with minimal setup and maintenance.

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

## Installation

### Install Dependencies

#### Ubuntu

```shell
sudo apt update
sudo apt install -y ruby-full build-essential zlib1g-dev git
```
#### Arch

```shell
sudo pacman -Syu
sudo pacman -S ruby ruby-rdoc gcc make --noconfirm
```

To avoid installing RubyGems packages as the root user:

If you are using `bash` (usually the default for most)

```bash
echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc && \
echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc && \
echo 'export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH"' >> ~/.bashrc && \
source ~/.bashrc
```

If you are using `zsh` (you know if you are)

```bash
echo '# Install Ruby Gems to ~/gems' >> ~/.zshrc && \
echo 'export GEM_HOME="$HOME/gems"' >> ~/.zshrc && \
echo 'export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH"' >> ~/.zshrc && \
source ~/.zshrc
```

### Install Jekyll Bundler

```bash
gem update --user-install
gem install jekyll bundle --user-install
```

## Creating a site based on Starter Template

Templates <https://pinglestudio.peopleforce.io/knowledge_base/articles/46782>{:target="_blank"}

After selecting a Jekyll template, you can fork it and follow the setup instructions in the `README.md` file.

### Site Configuration

#### Comments Section /W Giscus

Choose the repository giscus will connect to. Make sure that:

1. The repository is `public`, otherwise visitors will not be able to view the discussion.
2. The [Giscus app](https://giscus.app/){:target="_blank"} is installed, otherwise visitors will not be able to comment and react.
3. The Discussions feature is turned on by [enabling it for your repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/enabling-or-disabling-github-discussions-for-a-repository){:target="_blank"}.
4. Create dedicated section for `Comments`.

Get info from GitHub `Repository ID` && `Comments Category ID`:

```bash
gh api graphql -f query='
{
  repository(owner: "jokerwrld999", name: "jokerwrld.github.io") {
    id # RepositoryID
    name
    discussionCategories(first: 10) {
      nodes {
        id # CategoryID
        name
      }
    }
  }
}'
```

Finally, complete your data in `_config.yml` file:

```yml
giscus:
    repo: jokerwrld999/jokerwrld.github.io # <gh-username>/<repo>
    repo_id:
    category: Comments
    category_id:
    mapping: pathname # optional, default to 'pathname'
    input_position: bottom # optional, default to 'bottom'
    lang: en # optional, default to the value of `site.lang`
    reactions_enabled: 1 # optional, default to the value of `1`
```

## Jekyll Commands

### Recommended Plugin For Extending Jekyll Commands

Jekyll Compose <https://github.com/jekyll/jekyll-compose>{:target="_blank"}

Set default front matter for drafts and posts in `_config.yml` file in site root directory

```yml
jekyll_compose:
  default_front_matter:
    drafts:
      image:
        path: /assets/img/2023/thumbs/default.webp
      categories:
        - homelab
        - linux
        - hardware
      tags:
        - servers
        - ubuntu
    posts:
      image:
        path: /assets/img/2023/thumbs/default.webp
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


Serving your site

```bash
bundle exec jekyll s
```

Building your site in production mode

```bash
JEKYLL_ENV=production bundle exec jekyll b
```

## Deploy on GitHub Actions

### Configure the `Pages` service

1. Browse to your repository on GitHub. Select the tab `Settings`, then click `Pages` in the left navigation bar. Then, in the `Source` section (under Build and deployment), select [GitHub Actions](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow){:target="_blank"} from the dropdown menu.
![Github Pages](/assets/img/2023/posts/jekyll-pages-source.webp)

2. Push any commits to GitHub to trigger the `Actions workflow`. In the `Actions` tab of your repository, you should see the workflow `Build and Deploy` running. Once the build is complete and successful, the site will be deployed automatically.

### Set Custom Domain

1. Update DNS Records:
![Cloudflare DNS Records](/assets/img/2023/posts/jekyll-dns-records.webp)

2. Enable HTTPS on Cloudflare:
- In Cloudflare, go to the SSL/TLS section and configure SSL to your liking.
- Ensure the SSL mode is set to `Full` or `Full (strict)`.

3. Configure GitHub Pages:
- Navigate to the repository's settings.
- Under the `GitHub Pages` section, add your custom domain (e.g., example.com).


## Creating a Post

### Naming Conventions

Jekyll uses a naming [convention for pages and posts](https://jekyllrb.com/docs/posts/){:target="_blank"}

Create a file in `_posts` with the format

```file
YEAR-MONTH-DAY-title.md
```

For example:

```file
2023-05-23-homelab-docs.md
2023-07-09-hardware-specs.md
```

> Jekyll can delay posts which have the date/time set for a point in the future determined by the "front matter" section at the top of your post file. Check the date & time as well as time zone if you don't see a post appear shortly after re-build.
{: .prompt-tip }

### Local Linking of Files

Image from asset:

```markdown
... which is shown in the screenshot below:
![A screenshot](/assets/img/2023/posts/*.webp)
```

Linking to a file

```markdown
... you can [download the PDF](/assets/diagram.pdf) here.
```

See more post formatting rules on the [Jekyll site](https://jekyllrb.com/docs/posts/){:target="_blank"}

### Markdown Examples

If you need some help with markdown, check out the [markdown cheat sheet](https://www.markdownguide.org/cheat-sheet/){:target="_blank"}

### Jekyll Full Workflow

![Creating post workflow](/assets/img/2023/posts/jekyll-workflow-diagram.webp)

1. **Create Your New Draft:**

    ```bash
    bundle exec jekyll draft "My new draft"
    ```

    Useful alias:

    ```bash
    alias draft="bundle exec jekyll draft"
    ```

2. **Serve Your Website with Drafts:**

    ```bash
    bundle exec jekyll s --drafts
    ```

    Useful alias:

    ```bash
    alias jekyll="bundle exec jekyll s --drafts"
    ```

    Now, you can see your changes dynamically while writing your draft on [`http://127.0.0.1:4000/`](http://127.0.0.1:4000/){:target='_blank'}

3. **Publish Your Draft:**

    After finishing your draft you can publish it, so that it will be available in posts.

    ```bash
    bundle exec jekyll publish _drafts/my-new-draft.md
    ```

    Useful alias:

    ```bash
    publish_draft() {
        if [ ! -d "_posts/$1" ]; then
            mkdir -p "_posts/$1"
        fi
        draft_filename="$(find ./_drafts/ -type f -name $2*.md -printf "%f\n")"
        bundle exec jekyll publish "./_drafts/$draft_filename" | grep -oP '_posts/.*?\.md' | xargs basename | read filename
        mv "_posts/$filename" "_posts/$1/$filename"
    }

    alias publish='publish_draft'

    publish "<YOUR-SUBFOLDER>" "<POST-NAME>"
    ```

You don't actually need to start a new post from a draft, but it's highly recommended.

Here are some helpful aliases:

  ```bash
  new_post() {
      if [ ! -d "_posts/$1" ]; then
          mkdir -p "_posts/$1"
      fi
      bundle exec jekyll post "$2" | grep -oP '_.*?\.md' | xargs basename | read filename
      mv "_posts/$filename" "_posts/$1/$filename"
  }

  alias post='new_post'

  post "<YOUR-SUBFOLDER>" "<POST-NAME>"
  ```
