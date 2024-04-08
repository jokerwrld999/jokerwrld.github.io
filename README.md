# Documentation Website /W Jekyll

This repository hosts the source code for my personal documentation website. The website is built using Jekyll, a static site generator, making it easy to create and maintain documentation in a structured and organized manner.

## Features

  - **Jekyll-Powered:** Utilizes the power of Jekyll to transform plain text into static websites and blogs.
  - **Responsive Design:** The website is designed to be accessible and usable across various devices and screen sizes.
  - **Easy to Navigate:** Intuitive navigation to help users quickly find the information they need.
  - **Secure and Trustworthy:** HTTPS and SSL configured via Cloudflare to ensure a secure and encrypted connection.

### Usage

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

Install dependencies

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
