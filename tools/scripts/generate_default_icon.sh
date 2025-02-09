#!/bin/bash

# Required parameters:
# --app-name "App Name"
# --output-dir "path/to/output"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --app-name) APP_NAME="$2"; shift ;;
        --output-dir) OUTPUT_DIR="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$APP_NAME" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Missing required parameters"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Get first letter of app name
FIRST_LETTER=$(echo "$APP_NAME" | cut -c1 | tr '[:lower:]' '[:upper:]')

# Generate base icon with first letter
convert -size 1024x1024 xc:white \
    -font Arial-Bold -pointsize 512 \
    -gravity center \
    -fill "#007AFF" \
    -draw "text 0,0 '$FIRST_LETTER'" \
    -alpha set -background none \
    "$OUTPUT_DIR/icon_base.png"

# Add rounded corners and gradient
convert "$OUTPUT_DIR/icon_base.png" \
    \( +clone -alpha extract \
        -draw 'fill black polygon 0,0 0,15 15,0 fill white circle 15,15 15,0' \
        \( +clone -flip \) -compose Multiply -composite \
        \( +clone -flop \) -compose Multiply -composite \
    \) -alpha off -compose CopyOpacity -composite \
    "$OUTPUT_DIR/icon.png"

# Clean up temporary file
rm "$OUTPUT_DIR/icon_base.png"

# Generate all required iOS icon sizes
declare -a sizes=(
    "20x20" "29x29" "40x40" "58x58" "60x60" "76x76" "80x80" 
    "87x87" "120x120" "152x152" "167x167" "180x180" "1024x1024"
)

for size in "${sizes[@]}"; do
    convert "$OUTPUT_DIR/icon.png" -resize "$size" "$OUTPUT_DIR/icon_${size}.png"
done

echo "Generated default icon set for $APP_NAME in $OUTPUT_DIR"
