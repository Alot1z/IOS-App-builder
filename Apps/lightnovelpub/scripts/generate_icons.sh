#!/bin/bash

set -e

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --input) input="$2"; shift ;;
        --output) output="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate input
if [ -z "$input" ] || [ -z "$output" ]; then
    echo "Usage: $0 --input <input_icon.png> --output <output_dir>"
    exit 1
fi

# Create output directory
mkdir -p "$output"

# iOS icon sizes
declare -a sizes=(
    "20x20"
    "29x29"
    "40x40"
    "58x58"
    "60x60"
    "76x76"
    "80x80"
    "87x87"
    "120x120"
    "152x152"
    "167x167"
    "180x180"
    "1024x1024"
)

# Generate icons for each size
for size in "${sizes[@]}"; do
    width=${size%x*}
    height=${size#*x}
    echo "Generating ${size} icon..."
    magick "$input" -resize "${width}x${height}!" "$output/icon_${size}.png"
done

# Create Contents.json
cat > "$output/Contents.json" << EOF
{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "icon_40x40.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "icon_60x60.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "icon_58x58.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "icon_87x87.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "icon_80x80.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "icon_120x120.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "icon_120x120.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "icon_180x180.png",
      "scale" : "3x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "icon_20x20.png",
      "scale" : "1x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "icon_40x40.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "icon_29x29.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "icon_58x58.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "icon_40x40.png",
      "scale" : "1x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "icon_80x80.png",
      "scale" : "2x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "icon_76x76.png",
      "scale" : "1x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "icon_152x152.png",
      "scale" : "2x"
    },
    {
      "size" : "83.5x83.5",
      "idiom" : "ipad",
      "filename" : "icon_167x167.png",
      "scale" : "2x"
    },
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "icon_1024x1024.png",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOF

echo "Icon generation complete!"
