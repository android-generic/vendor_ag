#!/bin/bash
# Get the search string, replacement string, and starting location from the user
search_string="$1"
replacement_string="$2"
starting_location="$3"
# Find all files containing search string recursively
# files=$(grep -rl "$search_string" "$starting_location")
files=$(grep -rl "$search_string" "$starting_location")

echo "Files found: $files"

# Loop through each file and replace the search string with replacement string while preserving variables
for file in $files
do
    # Escape the forward slashes in the replacement string
    replacement_string_escaped=$(echo "$replacement_string" | sed 's/\//\\\//g')
    # Replace the search string with the escaped replacement string while preserving bash variables
    sed -i "s/$search_string/${replacement_string_escaped}/g" "$file"
done
echo "Strings replaced successfully."