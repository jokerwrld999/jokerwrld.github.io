#!/bin/bash

post_year="${2-$(date +%Y)}"

# Create directory if it doesn't exist
mkdir -p "_posts/$post_year" &>/dev/null

# Function to handle draft processing
process_draft() {
  # Get draft filename
  draft_filename=$(find ./_drafts/ -type f -name "$1*.md" -printf "%f\n" | head -n 1)
  
  # Check if draft exists
  if [[ -z "$draft_filename" ]]; then
    echo "Error: Draft file not found for '$1'"
    return 1
  fi

  # Extract filename from jekyll publish output
  filename=$(bundle exec jekyll publish "./_drafts/$draft_filename" | grep -oP '_posts/.*\.md' | awk -F'/' '{print $NF}')

  # Move the file
  mv "./_posts/$filename" "./_posts/$post_year/$filename"
}

# Function to handle new post creation
create_post() {
  # Get filename from jekyll post output
  filename=$(bundle exec jekyll post "$1" | grep -oP '_posts/.*\.md' | awk -F'/' '{print $NF}')

  # Move the file (assuming jekyll post creates the file)
  if [[ -f "./_posts/$filename" ]]; then
    mv "./_posts/$filename" "./_posts/$post_year/$filename"
  else
    echo "Warning: Jekyll post might not have created the file for '$1'"
  fi
}

# Check for action (draft or new)
action="${1:-}"

if [[ "$action" == "draft" ]]; then
  process_draft "$2"
elif [[ "$action" == "new" ]]; then
  create_post "$2"
else
  echo "Usage: $0 (draft|new) <post_name>"
fi
