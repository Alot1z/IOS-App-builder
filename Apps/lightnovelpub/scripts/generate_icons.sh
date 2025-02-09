#!/bin/bash

# Exit on error
set -e

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick is not installed. Please install it first."
    exit 1
fi

# Input validation
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <source_icon.png>"
    exit 1
fi

SOURCE_ICON="$1"

# Check if source icon exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo "Error: Source icon $SOURCE_ICON not found"
    exit 1
fi

# Create Assets.xcassets directory structure
mkdir -p "build/Assets.xcassets/AppIcon.appiconset"

# Function to generate icon
generate_icon() {
    local size="$1"
    local scale="$2"
    local target_size=$((size * scale))
    
    echo "Generating ${target_size}x${target_size} icon..."
    magick "$SOURCE_ICON" -resize "${target_size}x${target_size}" \
        "build/Assets.xcassets/AppIcon.appiconset/icon_${size}x${size}@${scale}x.png"
}

# Generate all required icon sizes
# iPhone
generate_icon 20 2  # 40x40
generate_icon 20 3  # 60x60
generate_icon 29 2  # 58x58
generate_icon 29 3  # 87x87
generate_icon 40 2  # 80x80
generate_icon 40 3  # 120x120
generate_icon 60 2  # 120x120
generate_icon 60 3  # 180x180

# iPad
generate_icon 20 1  # 20x20
generate_icon 20 2  # 40x40
generate_icon 29 1  # 29x29
generate_icon 29 2  # 58x58
generate_icon 40 1  # 40x40
generate_icon 40 2  # 80x80
generate_icon 76 1  # 76x76
generate_icon 76 2  # 152x152
generate_icon 83.5 2  # 167x167

# App Store
magick "$SOURCE_ICON" -resize 1024x1024 \
    "build/Assets.xcassets/AppIcon.appiconset/icon_1024x1024@1x.png"

# Generate Contents.json
cat > "build/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "icon_20x20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "icon_20x20@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "icon_29x29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "icon_29x29@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "icon_40x40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "icon_40x40@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "icon_60x60@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "icon_60x60@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "icon_20x20@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "icon_20x20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "icon_29x29@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "icon_29x29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "icon_40x40@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "icon_40x40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "icon_76x76@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "icon_76x76@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "83.5x83.5",
      "idiom" : "ipad",
      "filename" : "icon_83.5x83.5@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "icon_1024x1024@1x.png",
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
