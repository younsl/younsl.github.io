#!/bin/bash

# Print help message
print_usage() {
    echo "Usage: $0 [--dry-run]"
    echo "  --dry-run    Show commands without generating PDF"
}

# Parse arguments
DRY_RUN=0
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=1 ;;
        -h|--help) print_usage; exit 0 ;;
        *) echo "Unknown option: $1"; print_usage; exit 1 ;;
    esac
    shift
done

# Move to the script's directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

# Collect files to convert (sh-compatible version)
files_to_convert=()
find . -type f -name "slide-deck.md" > /tmp/slides_list.tmp
while IFS= read -r slide_path; do
    files_to_convert+=("$slide_path")
done < /tmp/slides_list.tmp
rm /tmp/slides_list.tmp

# Check if no files found
if [ ${#files_to_convert[@]} -eq 0 ]; then
    echo "No slide-deck.md files found to convert."
    exit 1
fi

# Show files to be converted
echo "The following files will be converted to PDF:"
for file in "${files_to_convert[@]}"; do
    echo "- $file"
done

# Get user confirmation
read -p "Proceed with conversion? (y/N) " response
if [[ ! "$response" =~ ^[yY]$ ]]; then
    echo "PDF conversion cancelled."
    exit 0
fi

# First remove all existing PDF files in content/slides directory
if [ $DRY_RUN -eq 0 ]; then
    echo "Removing existing PDF files in content/slides:"
    find "$script_dir" -maxdepth 1 -type f -name "*.pdf" -print -exec rm {} \;
fi

# Process each file
for slide_path in "${files_to_convert[@]}"; do
    dir_path=$(dirname "$slide_path")
    dir_name=$(basename "$dir_path")
    output_file="$script_dir/${dir_name}.pdf"
    
    if [ $DRY_RUN -eq 1 ]; then
        echo "[DRY-RUN] Following command will be executed:"
        echo "cd $dir_path && podman run --rm --init -v $PWD:/home/marp/app/ -v $script_dir:/home/marp/output/ -e LANG=$LANG marpteam/marp-cli slide-deck.md --pdf --allow-local-files --output /home/marp/output/${dir_name}.pdf"
    else
        echo "Converting: $slide_path to $output_file"
        
        # content/slides/{dir_name}/slide-deck.md -> content/slides/{dir_name}.pdf
        cd "$dir_path" && \
        podman run --rm --init \
            -v $PWD:/home/marp/app/ \
            -v "$script_dir":/home/marp/output/ \
            -e LANG=$LANG \
            marpteam/marp-cli \
            slide-deck.md --pdf --allow-local-files --output "/home/marp/output/${dir_name}.pdf"
        
        if [ $? -eq 0 ]; then
            echo "Successfully created $output_file"
        else
            echo "Error creating PDF for $slide_path"
        fi
        cd "$script_dir"
    fi
done

# Display information about generated PDF files
if [ $DRY_RUN -eq 0 ]; then
    pdf_count=$(find "$script_dir" -maxdepth 1 -type f -name "*.pdf" | wc -l)
    echo "===========================================" 
    echo "Total $pdf_count PDF files have been generated:"
    find "$script_dir" -maxdepth 1 -type f -name "*.pdf" | sort | while read -r pdf_file; do
        file_size=$(du -h "$pdf_file" | cut -f1)
        echo "- $(basename "$pdf_file") ($file_size)"
    done
    echo "Location: $script_dir"
    echo "===========================================" 
fi