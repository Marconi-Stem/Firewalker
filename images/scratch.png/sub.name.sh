#!/bin/bash

# Directory containing the .png files (default to current directory if not specified)
TARGET_DIR="${1:-.}"
OUTPUT_FILE="image_list.md"

# Clear the output file if it exists, or create it
> "$OUTPUT_FILE"


# Check if the target directory exists
#if [ ! -d "$TARGET_DIR" ]; then
#    echo "Error: Directory '$TARGET_DIR' not found."
#    exit 1
#fi

# Navigate to the target directory
#cd "$TARGET_DIR" || { echo "Error: Could not change to directory '$TARGET_DIR'"; exit 1; }


# Loop through each .png file in the directory and append to the output file
for file in *.png; do
    # Check if any .png files were found (handles cases where no .png files exist)
    if [ -f "$file" ]; then
        # Get the filename without the extension
        filename_no_ext="${file%.*}"

        # Append the desired format to the output file
        echo "![${filename_no_ext}](${file})" >> "$OUTPUT_FILE"
    fi
done

echo "Filenames saved to: '$TARGET_DIR/$OUTPUT_FILE'"

# Return to the original directory (optional, but good practice)
# cd - > /dev/null

# Return to the original directory (optional, but good practice)
# cd - > /dev/null
```
