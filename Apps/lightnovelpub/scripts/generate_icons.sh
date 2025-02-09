#!/bin/bash

# Exit on error
set -e

# Icon cache directory
CACHE_DIR="build/icon-cache"
ASSETS_DIR="assets"
SOURCE_ICON="$ASSETS_DIR/Light_Novel_pub_Icon.png" # Using existing LightNovelPub icon
OUTPUT_DIR="build/Assets.xcassets/AppIcon.appiconset"

# Required sizes for iOS app icons
declare -A ICON_SIZES=(
    ["iphone_notification_20pt@2x"]="40x40"
    ["iphone_notification_20pt@3x"]="60x60"
    ["iphone_settings_29pt@2x"]="58x58"
    ["iphone_settings_29pt@3x"]="87x87"
    ["iphone_spotlight_40pt@2x"]="80x80"
    ["iphone_spotlight_40pt@3x"]="120x120"
    ["iphone_app_60pt@2x"]="120x120"
    ["iphone_app_60pt@3x"]="180x180"
    ["ipad_notifications_20pt@1x"]="20x20"
    ["ipad_notifications_20pt@2x"]="40x40"
    ["ipad_settings_29pt@1x"]="29x29"
    ["ipad_settings_29pt@2x"]="58x58"
    ["ipad_spotlight_40pt@1x"]="40x40"
    ["ipad_spotlight_40pt@2x"]="80x80"
    ["ipad_app_76pt@1x"]="76x76"
    ["ipad_app_76pt@2x"]="152x152"
    ["ipad_pro_129_83.5pt@2x"]="167x167"
)

# Create directories if they don't exist
mkdir -p "$CACHE_DIR"
mkdir -p "$OUTPUT_DIR"

# Check if source icon exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo "Error: Source icon $SOURCE_ICON not found!"
    exit 1
fi

# Get source icon dimensions
SOURCE_SIZE=$(sips -g pixelWidth -g pixelHeight "$SOURCE_ICON" | grep -E 'pixel(Width|Height): ' | cut -d: -f2 | tr -d ' ' | sort -nr | head -n1)

# Function to check if cached icon is up to date
is_cached() {
    local size="$1"
    local cache_file="$CACHE_DIR/icon_${size}.png"
    
    if [ -f "$cache_file" ]; then
        if [ "$SOURCE_ICON" -ot "$cache_file" ]; then
            return 0 # Cache is valid
        fi
    fi
    return 1 # Cache needs update
}

# Function to generate icon using sips (native macOS tool)
generate_icon() {
    local size="$1"
    local output="$2"
    local dimensions="${size%x*}"
    
    if [ "$SOURCE_SIZE" -lt "$dimensions" ]; then
        echo "Warning: Source icon is smaller than required size $size"
    fi
    
    # Use sips for resizing (much faster than ImageMagick)
    sips -z "$dimensions" "$dimensions" "$SOURCE_ICON" --out "$output" >/dev/null 2>&1
}

# Generate Contents.json
cat > "$OUTPUT_DIR/Contents.json" << EOF
{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "iphone_notification_20pt@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "iphone_notification_20pt@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "iphone_settings_29pt@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "iphone_settings_29pt@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "iphone_spotlight_40pt@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "iphone_spotlight_40pt@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "iphone_app_60pt@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "iphone_app_60pt@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "ipad_notifications_20pt@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "ipad_notifications_20pt@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "ipad_settings_29pt@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "ipad_settings_29pt@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "ipad_spotlight_40pt@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "ipad_spotlight_40pt@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "ipad_app_76pt@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "ipad_app_76pt@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "83.5x83.5",
      "idiom" : "ipad",
      "filename" : "ipad_pro_129_83.5pt@2x.png",
      "scale" : "2x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOF

# Generate icons using cache
for name in "${!ICON_SIZES[@]}"; do
    size="${ICON_SIZES[$name]}"
    cache_file="$CACHE_DIR/icon_${size}.png"
    output_file="$OUTPUT_DIR/${name}.png"
    
    echo "Processing $size icon..."
    
    if ! is_cached "$size"; then
        echo "Generating $size icon..."
        generate_icon "$size" "$cache_file"
    else
        echo "Using cached $size icon..."
    fi
    
    # Copy from cache to output
    cp "$cache_file" "$output_file"
done

echo "Icon generation complete!"
