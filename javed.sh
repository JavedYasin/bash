#!/bin/bash

# Enter directory path
read -p "Enter the directory path: " dir

echo $dir



if [ ! -d "$dir" ]; then
    echo "Error: Directory not found"
    exit 1
fi

read -p "Enter a regular expression pattern: " pattern

function file_changed {
    local file="$1"
    if grep -q "specific string" "$file"; then
        local value=$(awk '/specific string/ {print $3}' "$file")
        cp "$file" "backup/$file.bak"
        sed -i "s/specific string/new value/g" "$file"
        if [ $(wc -l < "$file") -gt 10 ]; then
            head -n 5 "$file" > "$file.top"
            tail -n 5 "$file" > "$file.bottom"
        fi
        tar -czvf "backup_$(date +%Y%m%d_%H%M%S).tar.gz" "backup"
    fi
}
inotifywait -m -e create,modify,delete "$dir" |
    while read path action file; do
        if [[ "$file" =~ $pattern ]]; then
            file_changed "$path$file"
        fi
    done
