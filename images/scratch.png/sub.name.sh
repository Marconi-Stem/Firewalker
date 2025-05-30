#!/bin/bash

# Directory containing the .png files (default to current directory if not specified)
TARGET_DIR="${1:-.}"
OUTPUT_FILE="image_list.md"

# Clear the output file if it exists, or create it
> "$OUTPUT_FILE"


# Seek *.png files process & append to output file
for file in *.png; do
    # Check for .png files
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
