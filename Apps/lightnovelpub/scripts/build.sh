#!/bin/bash

# Build script for LightNovel Pub iOS app
# Supports iOS 16.0-17.0

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

# Create directories with proper permissions
for dir in "$BUILD_DIR" "$DERIVED_DATA_DIR" "$INTERMEDIATE_DIR" "$PRODUCTS_DIR" "$LOGS_DIR" "$DEBUG_SYMBOLS_DIR"; do
    mkdir -p "$dir"
    chmod 755 "$dir"
done

# Verify directories exist
for dir in "$BUILD_DIR" "$DERIVED_DATA_DIR" "$INTERMEDIATE_DIR" "$PRODUCTS_DIR" "$LOGS_DIR" "$DEBUG_SYMBOLS_DIR"; do
    if [ ! -d "$dir" ]; then
        echo "Error: Failed to create directory: $dir"
        exit 1
    fi
    echo "Created directory: $dir"
done

# Set Swift build flags
SWIFT_BUILD_FLAGS=(
    "--configuration" "release"
    "--arch" "arm64"
    "--sdk" "$SDKROOT"
    "--package-path" "."
)

if [ "$build_type" = "release" ]; then
    SWIFT_BUILD_FLAGS+=("-Xswiftc" "-O")
fi

if [ "$enable_arc" = "true" ]; then
    SWIFT_BUILD_FLAGS+=("-Xswiftc" "-enable-objc-arc")
fi

# Compile Swift files
echo "Compiling Swift files..."
mkdir -p "$BUILD_DIR/release"

# Build using Swift Package Manager
swift build "${SWIFT_BUILD_FLAGS[@]}" 2>&1 | tee "$LOGS_DIR/build.log"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "Error: Swift build failed. Check $LOGS_DIR/build.log for details."
    exit 1
fi

# Create app bundle
APP_BUNDLE_DIR="$BUILD_DIR/LightNovelPub.app"
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
BINARY_PATH=".build/release/LightNovelPub"
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

# If root is enabled, add root components
if [ "$root_enabled" = "true" ]; then
    echo "Adding root components..."
    mkdir -p "$APP_BUNDLE_DIR/root"
    cp src/root/giveMeRoot.m "$APP_BUNDLE_DIR/root/" || {
        echo "Error: Failed to copy root components"
        exit 1
    }
fi

# If exploit is enabled, add exploit components
if [ "$exploit_enabled" = "true" ]; then
    echo "Adding exploit components..."
    mkdir -p "$APP_BUNDLE_DIR/exploits"
    cp -R src/exploits/* "$APP_BUNDLE_DIR/exploits/" || {
        echo "Error: Failed to copy exploit components"
        exit 1
    }
fi

# Copy debug symbols
if [ -d ".build/release" ]; then
    cp -R .build/release/*.dSYM "$DEBUG_SYMBOLS_DIR/" 2>/dev/null || true
fi

echo "Build completed successfully!"
ls -la "$APP_BUNDLE_DIR"
