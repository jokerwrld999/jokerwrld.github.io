#!/bin/bash

post_year="${2-$(date +%Y)}"

if [ ! -d "_posts/$post_year" ]; then
  mkdir -p "_posts/$post_year"
fi

filename="$(bundle exec jekyll post "$1" | grep -oP '_posts/.*?\.md' | xargs basename)"
mv "./_posts/$filename" "./_posts/$post_year/$filename"
