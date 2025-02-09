#!/bin/bash

# Icon generation script for LightNovel Pub iOS app
# Supports iOS 16.0-17.0 icon requirements

set -e

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --input) INPUT_ICON="$2"; shift ;;
        --output) OUTPUT_DIR="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate input
if [ ! -f "$INPUT_ICON" ]; then
    echo "Error: Input icon file not found: $INPUT_ICON"
    exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Error: Output directory not found: $OUTPUT_DIR"
    exit 1
fi

# Create Assets.xcassets structure
ASSETS_DIR="$OUTPUT_DIR/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$ASSETS_DIR"

# Define icon sizes for iOS 16-17
declare -A ICON_SIZES=(
    ["20x20"]="40 60"           # Notification
    ["29x29"]="58 87"           # Settings
    ["40x40"]="80 120"          # Spotlight
    ["60x60"]="120 180"         # iPhone App
    ["76x76"]="152 228"         # iPad App
    ["83.5x83.5"]="167"         # iPad Pro App
    ["1024x1024"]="1024"        # App Store
)

# Generate Contents.json
cat > "$ASSETS_DIR/Contents.json" << EOF
{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-40.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-60.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-58.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-87.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-80.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-120.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-120.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-180.png",
      "scale" : "3x"
    },
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "Icon-1024.png",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOF

# Generate icons using ImageMagick
for base_size in "${!ICON_SIZES[@]}"; do
    for size in ${ICON_SIZES[$base_size]}; do
        output_file="$ASSETS_DIR/Icon-$size.png"
        magick convert "$INPUT_ICON" -resize "${size}x${size}" "$output_file"
        echo "Generated: Icon-$size.png"
    done
done

echo "Icon generation complete!"
