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

{% tabs distro %}

{% tab distro Ubuntu %}
```shell
sudo apt update
sudo apt install -y ruby-full build-essential zlib1g-dev git
```
{% endtab %}

{% tab distro Arch %}
```shell
sudo pacman -Syu
sudo pacman -S ruby ruby-rdoc gcc make --noconfirm
```
{% endtab %}

{% endtabs %}

To avoid installing RubyGems packages as the root user update your shell profile:

{% tabs profile %}

{% tab profile Bash %}
```bash
tee -a ~/.bashrc > /dev/null <<EOF

# Install Ruby Gems to ~/gems
export GEM_HOME=\$HOME/gems
export PATH=\$HOME/.local/share/gem/ruby/3.0.0/bin:\$PATH
EOF
source ~/.bashrc
```
{% endtab %}

{% tab profile Zsh %}
```bash
tee -a ~/.zshrc > /dev/null <<EOF

# Install Ruby Gems to ~/gems
export GEM_HOME=\$HOME/gems
export PATH=\$HOME/.local/share/gem/ruby/3.0.0/bin:\$PATH
EOF
source ~/.zshrc
```
{% endtab %}

{% endtabs %}

### Install Jekyll Bundler

```bash
gem update --user-install
gem install jekyll bundle --user-install
```

## Creating a site based on Starter Template

Templates: <https://github.com/topics/jekyll-theme>{:target="_blank"}

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

#### Jekyll Tabs

Refer [Jekyll Tabs Project](https://github.com/Ovski4/jekyll-tabs){:target='_blank'} for usage info and more.

1. **Install the plugin:**

    Add this line to the end of your `Gemfile`:

    ```ruby
    group :jekyll_plugins do
      gem "jekyll-tabs"
    end
    ```

2. **Install the gem by running:**

    ```bash
    bundle install
    ```

3. **Then add the gem to the plugin list in your `_config.yml` file:**

    ```yaml
    plugins:
      - jekyll-tabs
    ```

4. **Style the tabs:**

    >Depending on your [Jekyll theme](https://jekyllrb.com/docs/themes/){:target='_blank'} configuration can be different. Reference your theme documentation on how to override defaults.
    {: .prompt-info}

    Locate a theme's files on you machine:

    ```bash
    bundle info --path chirpy
    ```

    After exploring theme's files you can  now override any theme file by creating a similarly named file in your Jekyll site directory.

    ```bash
    mkdir -p assets/css assets/js
    ```

    Copy the JavaScript content in your Jekyll site directory (for example `assets/js/tabs.js`).

    ```javascript
    !function(e,t){"object"==typeof exports&&"object"==typeof module?module.exports=t():"function"==typeof define&&define.amd?define([],t):"object"==typeof exports?exports.jekyllTabs=t():e.jekyllTabs=t()}(self,(()=>(()=>{"use strict";var e={973:(e,t,o)=>{o.r(t),o.d(t,{addClass:()=>r,createElementFromHTML:()=>s,findElementsWithTextContent:()=>n,getChildPosition:()=>a});const a=e=>{const t=e.parentNode;for(let o=0;o<t.children.length;o++)if(t.children[o]===e)return o},n=(e,t)=>{const o=document.querySelectorAll(e),a=[];for(let e=0;e<o.length;e++){const n=o[e];n.textContent.trim()===t.trim()&&a.push(n)}return a},s=e=>{const t=document.createElement("template");return t.innerHTML=e.trim(),t.content.firstChild},r=(e,t,o)=>{e.className=e.className?`${e.className} ${t}`:t,setTimeout((()=>{e.className=e.className.replace(t,"").trim()}),o)}},39:(e,t,o)=>{o.r(t),o.d(t,{activateTabFromUrl:()=>d,addCopyToClipboardButtons:()=>u,appendToastMessageHTML:()=>b,copyToClipboard:()=>c,handleTabClicked:()=>i,removeActiveClasses:()=>l,syncTabsWithSameLabels:()=>y,updateUrlWithActiveTab:()=>p});const{getChildPosition:a,createElementFromHTML:n,findElementsWithTextContent:s,addClass:r}=o(973),l=e=>{const t=e.querySelectorAll("ul > li");Array.prototype.forEach.call(t,(e=>{e.classList.remove("active")}))},i=e=>{const t=e.parentNode,o=t.parentNode,n=a(t);if(t.className.includes("active"))return;const s=o.getAttribute("data-tab");if(!s)return;const r=document.getElementById(s);l(o),l(r),r.querySelectorAll("ul.tab-content > li")[n].classList.add("active"),t.classList.add("active")},c=(e,t)=>{if(navigator.clipboard&&window.isSecureContext)navigator.clipboard.writeText(e);else{const t=document.createElement("textarea");t.value=e,t.style.position="absolute",t.style.left="-999999px",document.body.prepend(t),t.select();try{document.execCommand("copy")}catch(e){console.error(e)}finally{t.remove()}}"function"==typeof t&&t()},d=()=>{var e;const t=null===(e=window.location.hash)||void 0===e?void 0:e.substring(1);if(!t)return;const o=document.getElementById(t);if(!o)return;const a=new URLSearchParams(window.location.search).get("active_tab");if(!a)return;const n=o.querySelector("li#"+a+" > a");n&&i(n)},p=e=>{const t=e.parentNode,o=t.parentNode,a=new URLSearchParams(window.location.search);a.set("active_tab",t.id);const n=window.location.pathname+"?"+a.toString()+"#"+o.id;history.replaceState(null,"",n)},u=({buttonHTML:e,showToastMessageOnCopy:t,toastDuration:o})=>{const a=document.querySelectorAll("ul.tab-content > li pre");for(let s=0;s<a.length;s++){const r=a[s],l=r.parentNode,i=n(e);let d;l.style.position="relative",i.style.position="absolute",i.style.top="0px",i.style.right="0px",l.appendChild(i),t&&(d=()=>{m(o)}),i.addEventListener("click",(()=>{c(r.innerText,d)}))}},b=e=>{const t=document.createElement("div");t.id="jekyll-tabs-copy-to-clipboard-message",t.textContent=e,document.getElementsByTagName("body")[0].appendChild(t)},m=e=>{r(document.getElementById("jekyll-tabs-copy-to-clipboard-message"),"show",e)},y=e=>{const t=s("a",e.textContent);for(let o=0;o<t.length;o++)t[o]!==e&&i(t[o])}}},t={};function o(a){var n=t[a];if(void 0!==n)return n.exports;var s=t[a]={exports:{}};return e[a](s,s.exports,o),s.exports}o.d=(e,t)=>{for(var a in t)o.o(t,a)&&!o.o(e,a)&&Object.defineProperty(e,a,{enumerable:!0,get:t[a]})},o.o=(e,t)=>Object.prototype.hasOwnProperty.call(e,t),o.r=e=>{"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})};var a={};return(()=>{o.r(a),o.d(a,{init:()=>i});const{activateTabFromUrl:e,updateUrlWithActiveTab:t,handleTabClicked:n,addCopyToClipboardButtons:s,syncTabsWithSameLabels:r,appendToastMessageHTML:l}=o(39),i=(o={})=>{const a={syncTabsWithSameLabels:!1,activateTabFromUrl:!1,addCopyToClipboardButtons:!1,copyToClipboardSettings:{buttonHTML:"<button>Copy</button>",showToastMessageOnCopy:!1,toastMessage:"Code copied to clipboard",toastDuration:3e3}},i=Object.assign(Object.assign(Object.assign({},a),o),{copyToClipboardSettings:Object.assign(Object.assign({},a.copyToClipboardSettings),o.copyToClipboardSettings)}),c=document.querySelectorAll("ul.tab > li > a");if(Array.prototype.forEach.call(c,(e=>{e.addEventListener("click",(o=>{o.preventDefault(),n(e),i.activateTabFromUrl&&t(e),i.syncTabsWithSameLabels&&r(e)}),!1)})),i.addCopyToClipboardButtons){const e=i.copyToClipboardSettings;s(e),e.showToastMessageOnCopy&&l(e.toastMessage)}i.activateTabFromUrl&&e()}})(),a})()));

    window.addEventListener('load', function () {
        jekyllTabs.init();
    });
    ```
    {: file="assets/js/tabs.js"}

    Paste the CSS content in a file (for example `assets/css/custom.css`).

    ```css
    .tab {
      display: flex;
      flex-wrap: wrap;
      margin: 0 5px 15px 0;
      padding: 0;
      list-style: none;
      position: relative;
      transition: all 0.7s !important;
    }

    .content a:not(.img-link):hover {
      color: deepskyblue !important;
      transition: all 0.7s !important;
    }

    .tab > * {
      flex: none;
      padding-left: 5px;
      position: relative;
    }

    .tab > * > a {
      display: block;
      text-align: center;
      padding: 3pt 40pt;
      color: #fff;
      background-color: #26292c;
      border-top: none !important;
      border-bottom: 5px solid transparent !important;
      border-image-slice: 1;
      border-radius: 7px 7px 0 0 !important;
      font-size: 8pt;
      font-weight: 800 !important;
      text-transform: uppercase;
      line-height: 20px;
      border-radius: 5px;
      cursor: pointer;
    }

    .tab > .active > a {
      color: deepskyblue;
      border-top: none !important;
      border-bottom: 5px solid transparent;
      border-image: linear-gradient( 113deg, hsl(260deg 100% 64%) 0%, hsl(190deg 100% 55%) 100% );
      border-image-slice: 1;
      width:100%;
    }

    .tab-content {
      padding: 0;
    }

    .tab-content > li {
      display: none;
    }

    .tab-content > li.active {
        display: block;
        padding-left: 10pt;
    }

    ```
    {: file="assets/css/custom.css"}

5. **Include the javascript and css files:**

    Include the files in your `_includes` (such as `_includes/head.html`).

    ```html
    <head>
      ...
      <!-- Jekyll Tabs Stylesheet -->
      <link rel="stylesheet" href="/assets/css/custom.css">

      <!-- JavaScript -->
      <!-- Jekyll Tabs -->
      <script src="/assets/js/tabs.js"></script>
    </head>
    ```
    {: file="_includes/head.html}

6. **Here is the result:**

    ![Example to demo how tabs will render](/assets/img/2023/posts/jekyll-tabs-example.webp)

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

Install gem dependencies

```bash
bundle install
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

```vim
YEAR-MONTH-DAY-title.md
```

For example:

```vim
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
