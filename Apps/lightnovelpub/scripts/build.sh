#!/bin/bash

# Build script for LightNovel Pub iOS app
# Supports iOS 16.0-17.0 for root features, but app works on all iOS versions

set -e
set -x  # Enable debug output

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
        --build-type) build_type="$2"; shift ;;
        --root-enabled) root_enabled="$2"; shift ;;
        --exploit-enabled) exploit_enabled="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Required environment variables
if [ -z "$SDKROOT" ]; then
    echo "Error: SDKROOT environment variable not set"
    exit 1
fi

# Validate iOS version
if [ -z "$ios_version" ] || [ -z "$min_ios_version" ] || [ -z "$max_ios_version" ]; then
    echo "Error: iOS version parameters missing"
    exit 1
fi

# Set up build directories
echo "Setting up build directories..."
BUILD_DIR="build"
DERIVED_DATA_DIR="$BUILD_DIR/DerivedData"
INTERMEDIATE_DIR="$DERIVED_DATA_DIR/Build/Intermediates.noindex"
PRODUCTS_DIR="$DERIVED_DATA_DIR/Build/Products"
LOGS_DIR="$BUILD_DIR/logs"
DEBUG_SYMBOLS_DIR="$BUILD_DIR/debug-symbols"
ROOT_DIR="$BUILD_DIR/root"
EXPLOITS_DIR="$BUILD_DIR/exploits"

# Create directories with proper permissions
for dir in "$BUILD_DIR" "$DERIVED_DATA_DIR" "$INTERMEDIATE_DIR" "$PRODUCTS_DIR" "$LOGS_DIR" "$DEBUG_SYMBOLS_DIR" "$ROOT_DIR" "$EXPLOITS_DIR"; do
    mkdir -p "$dir"
    chmod 755 "$dir"
done

# Verify directories exist
for dir in "$BUILD_DIR" "$DERIVED_DATA_DIR" "$INTERMEDIATE_DIR" "$PRODUCTS_DIR" "$LOGS_DIR" "$DEBUG_SYMBOLS_DIR" "$ROOT_DIR" "$EXPLOITS_DIR"; do
    if [ ! -d "$dir" ]; then
        echo "Error: Failed to create directory: $dir"
        exit 1
    fi
    echo "Created directory: $dir"
done

# Find all Swift source files
SWIFT_FILES=(src/*.swift)
echo "Found Swift files: ${SWIFT_FILES[*]}"

# Set compilation flags
COMPILE_FLAGS=(
    "-target" "arm64-apple-ios${min_ios_version}"
    "-sdk" "$SDKROOT"
    "-g"
    "-swift-version" "5"
    "-module-name" "LightNovelPub"
)

# Handle optimization level
case $optimization_level in
    0) COMPILE_FLAGS+=("-Onone") ;;
    1) COMPILE_FLAGS+=("-O") ;;
    2|3) COMPILE_FLAGS+=("-O") ;;
    *) COMPILE_FLAGS+=("-O") ;;
esac

if [ "$enable_arc" = "true" ]; then
    COMPILE_FLAGS+=("-enable-objc-arc")
fi

if [ "$build_type" = "release" ]; then
    COMPILE_FLAGS+=("-whole-module-optimization")
fi

# Add frameworks
FRAMEWORK_FLAGS=(
    "-F" "$SDKROOT/System/Library/Frameworks"
    "-framework" "UIKit"
    "-framework" "WebKit"
    "-framework" "SafariServices"
    "-framework" "UserNotifications"
    "-framework" "SwiftUI"
)

# Create output directory
mkdir -p "$BUILD_DIR/release"

# Update icon generation script to use magick instead of convert
if [ -f "scripts/generate_icons.sh" ]; then
    sed -i 's/convert/magick/g' "scripts/generate_icons.sh"
fi

# Compile Swift files
echo "Compiling Swift files..."
xcrun -sdk iphoneos swiftc "${COMPILE_FLAGS[@]}" \
    "${FRAMEWORK_FLAGS[@]}" \
    "${SWIFT_FILES[@]}" \
    -o "$BUILD_DIR/release/LightNovelPub" 2>&1 | tee "$LOGS_DIR/build.log"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "Error: Swift compilation failed. Check $LOGS_DIR/build.log for details."
    exit 1
fi

# Create app bundle
APP_BUNDLE_DIR="$BUILD_DIR/LightNovel Pub.app"
mkdir -p "$APP_BUNDLE_DIR"
chmod 755 "$APP_BUNDLE_DIR"

echo "Copying resources..."
# Copy resources
if [ -d "resources" ]; then
    cp -R resources/* "$APP_BUNDLE_DIR/" || {
        echo "Error: Failed to copy resources"
        exit 1
    }
fi

# Copy Info.plist
if [ -f "build/Info.plist" ]; then
    cp build/Info.plist "$APP_BUNDLE_DIR/" || {
        echo "Error: Failed to copy Info.plist"
        exit 1
    }
fi

# Copy binary
BINARY_PATH="$BUILD_DIR/release/LightNovelPub"
if [ -f "$BINARY_PATH" ]; then
    cp "$BINARY_PATH" "$APP_BUNDLE_DIR/" || {
        echo "Error: Failed to copy binary"
        exit 1
    }
    chmod 755 "$APP_BUNDLE_DIR/LightNovelPub"
else
    echo "Error: Binary not found at $BINARY_PATH"
    exit 1
fi

# Handle root components (iOS 16.0-17.0 only)
if [ "$root_enabled" = "true" ]; then
    echo "Adding root components..."
    mkdir -p "$APP_BUNDLE_DIR/root"
    
    # Copy root files from tools/root
    cp -R ../../tools/root/* "$ROOT_DIR/" || {
        echo "Error: Failed to copy root components from tools"
        exit 1
    }
    
    # Process root files for iOS version compatibility
    if [[ "$ios_version" =~ ^1[6-7]\. ]]; then
        echo "iOS version $ios_version supports root features"
        cp -R "$ROOT_DIR"/* "$APP_BUNDLE_DIR/root/" || {
            echo "Error: Failed to copy processed root components"
            exit 1
        }
    else
        echo "iOS version $ios_version does not support root features - skipping"
    fi
fi

# Handle exploit components (iOS 16.0-17.0 only)
if [ "$exploit_enabled" = "true" ]; then
    echo "Adding exploit components..."
    mkdir -p "$APP_BUNDLE_DIR/exploits"
    
    # Copy exploit files
    if [[ "$ios_version" =~ ^1[6-7]\. ]]; then
        echo "iOS version $ios_version supports exploit features"
        cp -R src/exploits/* "$APP_BUNDLE_DIR/exploits/" || {
            echo "Error: Failed to copy exploit components"
            exit 1
        }
    else
        echo "iOS version $ios_version does not support exploit features - skipping"
    fi
fi

# Copy debug symbols if they exist
if [ -f "$BUILD_DIR/release/LightNovelPub.dSYM" ]; then
    cp -R "$BUILD_DIR/release/LightNovelPub.dSYM" "$DEBUG_SYMBOLS_DIR/" || true
fi

echo "Build completed successfully!"
ls -la "$APP_BUNDLE_DIR"
