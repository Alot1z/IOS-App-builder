#!/bin/bash

# Build script for Android Emulator iOS app
set -e
set -x

# Required environment variables
if [ -z "$SDKROOT" ]; then
    echo "Error: SDKROOT environment variable not set"
    exit 1
fi

# Download Android x86 and LDPlayer resources
RESOURCES_DIR="resources"
mkdir -p "$RESOURCES_DIR"

# Download Android x86 kernel
echo "Downloading Android x86 kernel..."
curl -L "https://sourceforge.net/projects/android-x86/files/latest/download" -o "$RESOURCES_DIR/android-x86.iso"

# Extract kernel and system files
7z x "$RESOURCES_DIR/android-x86.iso" -o"$RESOURCES_DIR/android-x86"

# Copy required files
cp "$RESOURCES_DIR/android-x86/kernel" "$RESOURCES_DIR/kernel.bin"
cp "$RESOURCES_DIR/android-x86/system.img" "$RESOURCES_DIR/system.img"

# Set up build directories
BUILD_DIR="build"
DERIVED_DATA_DIR="$BUILD_DIR/DerivedData"
PRODUCTS_DIR="$BUILD_DIR/Products"
mkdir -p "$BUILD_DIR" "$DERIVED_DATA_DIR" "$PRODUCTS_DIR"

# Compile Swift files
echo "Compiling Swift files..."
xcrun -sdk iphoneos swiftc \
    -target arm64-apple-ios16.0 \
    -sdk "$SDKROOT" \
    -O \
    -framework UIKit \
    -framework Metal \
    -framework MetalKit \
    -framework AVFoundation \
    src/*.swift \
    -o "$BUILD_DIR/AndroidEmulator"

# Create app bundle
APP_BUNDLE="$BUILD_DIR/Android Emulator.app"
mkdir -p "$APP_BUNDLE"

# Copy binary
cp "$BUILD_DIR/AndroidEmulator" "$APP_BUNDLE/"
chmod +x "$APP_BUNDLE/AndroidEmulator"

# Copy resources
mkdir -p "$APP_BUNDLE/Resources"
cp -R "$RESOURCES_DIR"/* "$APP_BUNDLE/Resources/"

# Create Info.plist
cat > "$APP_BUNDLE/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>AndroidEmulator</string>
    <key>CFBundleIdentifier</key>
    <string>com.androidemulator.app</string>
    <key>CFBundleName</key>
    <string>Android Emulator</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
        <string>metal</string>
    </array>
    <key>UIDeviceFamily</key>
    <array>
        <integer>1</integer>
        <integer>2</integer>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
EOF

# Create IPA for TrollStore
echo "Creating IPA for TrollStore..."
mkdir -p "Payload"
cp -r "$APP_BUNDLE" "Payload/"
zip -r "AndroidEmulator.ipa" "Payload"
rm -rf "Payload"

echo "Build completed! IPA is ready for TrollStore."
