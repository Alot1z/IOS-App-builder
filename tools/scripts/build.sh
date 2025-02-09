#!/bin/bash

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$TOOLS_DIR/../build"
IPA_DIR="$BUILD_DIR/ipa"
APP_DIR="$IPA_DIR/Payload/TrollStore.app"

# Ensure tools are executable
chmod +x "$TOOLS_DIR"/{ldid,choma,unzip}

# Function to patch and sign a binary
patch_and_sign() {
    local binary="$1"
    local entitlements="$2"

    # Patch binary with choma
    "$TOOLS_DIR/choma" --patch-sandbox "$binary"
    "$TOOLS_DIR/choma" --enable-jit "$binary"
    "$TOOLS_DIR/choma" --enable-debug "$binary"
    "$TOOLS_DIR/choma" --enable-root "$binary"

    # Sign with ldid
    "$TOOLS_DIR/ldid" -S"$entitlements" "$binary"
}

# Create build directories
mkdir -p "$APP_DIR"

# Build TrollStore
xcodebuild -project TrollStore.xcodeproj -scheme TrollStore -configuration Release -derivedDataPath "$BUILD_DIR/DerivedData"

# Copy app bundle
cp -R "$BUILD_DIR/DerivedData/Build/Products/Release-iphoneos/TrollStore.app/" "$APP_DIR/"

# Patch and sign binaries
patch_and_sign "$APP_DIR/TrollStore" "$TOOLS_DIR/entitlements.plist"

# Create IPA
cd "$IPA_DIR"
"$TOOLS_DIR/unzip" -r "../TrollStore.ipa" Payload/

echo "Build complete! IPA available at: $BUILD_DIR/TrollStore.ipa"
