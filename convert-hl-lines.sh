#!/bin/bash
# Convert Hugo hl_lines syntax to Zola syntax

echo "Converting hl_lines syntax from Hugo to Zola format..."

# Find all markdown files in content directory
find content -name "*.md" -type f | while read -r file; do
    # Check if file contains hl_lines
    if grep -q '{hl_lines' "$file"; then
        echo "Processing: $file"

        # Convert patterns like:
        # ```terraform {hl_lines=["4"]} -> ```terraform,hl_lines=4
        # ```bash {hl_lines=[26]} -> ```bash,hl_lines=26
        # ```bash {hl_lines=["5","8"]} -> ```bash,hl_lines=5 8
        # ```yaml {hl_lines=["3-5","8"]} -> ```yaml,hl_lines=3-5 8

        # First, handle single numbers without quotes: {hl_lines=[26]}
        perl -i -pe 's/```(\w+) \{hl_lines=\[(\d+)\]\}/```$1,hl_lines=$2/g' "$file"

        # Then handle quoted arrays: {hl_lines=["4","8"]}
        perl -i -pe 's/```(\w+) \{hl_lines=\[(.*?)\]\}/```$1,hl_lines=$2/g' "$file"

        # Remove quotes and commas from the line numbers
        perl -i -pe 's/(hl_lines=)"([^"]+)"/\1\2/g' "$file"
        perl -i -pe 's/(hl_lines=[^,\s]+),([^\s]+)/\1 \2/g' "$file"

        echo "  ✓ Converted hl_lines"
    fi
done

echo ""
echo "✓ Conversion complete!"
echo ""
echo "Verifying remaining Hugo-style hl_lines..."
remaining=$(grep -r '{hl_lines' content --include="*.md" | wc -l)
echo "Remaining Hugo-style hl_lines: $remaining"
