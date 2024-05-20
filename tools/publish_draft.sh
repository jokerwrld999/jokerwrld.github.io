#!/bin/bash

if [ ! -d "_posts/$1" ]; then
  mkdir -p "_posts/$1"
fi

draft_filename="$(find ./_drafts/ -type f -name $2*.md -printf "%f\n")"
bundle exec jekyll publish "./_drafts/$draft_filename" | grep -oP '_posts/.*?\.md' | xargs basename | read filename
mv "_posts/$filename" "_posts/$1/$filename"