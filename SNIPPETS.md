# Save things on obisdian vault

```zsh
  capture() {
      local file="/Volumes/matheus/knowledge-base/00_Inbox/Captures/$(date +%Y-%m-%d-%H%M%S).md"
      echo "$*" > "$file"
      echo "✓ Captured to $file"
  }
```