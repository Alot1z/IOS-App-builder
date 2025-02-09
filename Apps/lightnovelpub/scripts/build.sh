#!/bin/bash

# Build script for LightNovel Pub iOS app
# Supports iOS 16.0-17.0

set -e

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --ios-version) ios_version="$2"; shift ;;
        --app-version) app_version="$2"; shift ;;
        --min-ios-version) min_ios_version="$2"; shift ;;
        --max-ios-version) max_ios_version="$2"; shift ;;
        --optimization-level) optimization_level="$2"; shift ;;
        --enable-bitcode) enable_bitcode="$2"; shift ;;
        --enable-arc) enable_arc="$2"; shift ;;
        --deployment-target) deployment_target="$2"; shift ;;
        --entitlements) entitlements="$2"; shift ;;
        --features) features="$2"; shift ;;
        --dependencies) dependencies="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate iOS version
if [[ $(echo "$ios_version >= 16.0" | bc -l) -eq 0 ]] || [[ $(echo "$ios_version <= 17.0" | bc -l) -eq 0 ]]; then
    echo "Error: iOS version must be between 16.0 and 17.0"
    exit 1
fi

# Set up build directory
BUILD_DIR="build"
mkdir -p "$BUILD_DIR"

# Compile Swift files
echo "Compiling Swift files..."
swiftc -target arm64-apple-ios${deployment_target} \
    -sdk "$(xcrun --show-sdk-path --sdk iphoneos)" \
    -O${optimization_level} \
    ${enable_arc:+-enable-arc} \
    -framework UIKit \
    -framework WebKit \
    -framework SafariServices \
    -framework UserNotifications \
    -framework SwiftUI \
    src/*.swift \
    -o "$BUILD_DIR/LightNovelPub"

# Create app bundle
APP_BUNDLE="$BUILD_DIR/LightNovelPub.app"
mkdir -p "$APP_BUNDLE"
mv "$BUILD_DIR/LightNovelPub" "$APP_BUNDLE/"

# Generate Info.plist
echo "Generating Info.plist..."
"../../tools/scripts/create_plist.sh" \
    --bundle-id "com.alot1z.lightnovelpub" \
    --app-name "LightNovel Pub" \
    --app-version "$app_version" \
    --min-ios-version "$min_ios_version" \
    --max-ios-version "$max_ios_version" \
    --output "$APP_BUNDLE/Info.plist"

# Generate app icons
echo "Generating app icons..."
"../../tools/scripts/generate_icons.sh" \
    --input "assets/icon.png" \
    --output "$APP_BUNDLE"

# Sign the app
echo "Signing app..."
ENTITLEMENTS_FILE="$BUILD_DIR/entitlements.plist"
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>' > "$ENTITLEMENTS_FILE"

# Add entitlements
IFS=',' read -ra ENTITLEMENT_ARRAY <<< "$entitlements"
for entitlement in "${ENTITLEMENT_ARRAY[@]}"; do
    echo "    <key>$entitlement</key><true/>" >> "$ENTITLEMENTS_FILE"
done

echo '</dict>
</plist>' >> "$ENTITLEMENTS_FILE"

# Sign with ldid
"../../tools/bin/ldid" -S"$ENTITLEMENTS_FILE" "$APP_BUNDLE/LightNovelPub"

# Create IPA
echo "Creating IPA..."
mkdir -p "$BUILD_DIR/Payload"
cp -r "$APP_BUNDLE" "$BUILD_DIR/Payload/"
cd "$BUILD_DIR"
zip -r "LightNovelPub.ipa" "Payload"
cd ..

# Clean up
rm -rf "$BUILD_DIR/Payload"
rm -f "$ENTITLEMENTS_FILE"

echo "Build complete! IPA is at $BUILD_DIR/LightNovelPub.ipa"
