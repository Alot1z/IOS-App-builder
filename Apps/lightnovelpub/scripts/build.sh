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
BUILD_DIR="build"
DERIVED_DATA_DIR="$BUILD_DIR/DerivedData"
INTERMEDIATE_DIR="$DERIVED_DATA_DIR/Build/Intermediates.noindex"
PRODUCTS_DIR="$DERIVED_DATA_DIR/Build/Products"

mkdir -p "$BUILD_DIR" "$DERIVED_DATA_DIR" "$INTERMEDIATE_DIR" "$PRODUCTS_DIR"

# Set up compilation flags
SWIFT_FLAGS=(
    "-target" "arm64-apple-ios${deployment_target}"
    "-sdk" "$SDKROOT"
    "-O${optimization_level:-0}"
    "-g"  # Include debug symbols
    "-swift-version" "5"
    "-module-name" "LightNovelPub"
)

if [ "$enable_arc" = "true" ]; then
    SWIFT_FLAGS+=("-enable-objc-arc")
fi

if [ "$build_type" = "release" ]; then
    SWIFT_FLAGS+=("-whole-module-optimization")
fi

# Add frameworks
FRAMEWORKS=(
    "-framework" "UIKit"
    "-framework" "WebKit"
    "-framework" "SafariServices"
    "-framework" "UserNotifications"
    "-framework" "SwiftUI"
)

# Compile Swift files
echo "Compiling Swift files..."
swift build \
    --configuration release \
    --build-path "$BUILD_DIR" \
    --sdk "$SDKROOT" \
    --target "arm64-apple-ios${deployment_target}" \
    ${SWIFT_FLAGS[@]} \
    ${FRAMEWORKS[@]}

# Create app bundle
APP_BUNDLE_DIR="$BUILD_DIR/LightNovelPub.app"
mkdir -p "$APP_BUNDLE_DIR"

# Copy resources
cp -R resources/* "$APP_BUNDLE_DIR/"
cp build/Info.plist "$APP_BUNDLE_DIR/"

# Copy binary
cp "$BUILD_DIR/release/LightNovelPub" "$APP_BUNDLE_DIR/"

# If root is enabled, add root components
if [ "$root_enabled" = "true" ]; then
    echo "Adding root components..."
    mkdir -p "$APP_BUNDLE_DIR/root"
    cp src/root/giveMeRoot.m "$APP_BUNDLE_DIR/root/"
fi

# If exploit is enabled, add exploit components
if [ "$exploit_enabled" = "true" ]; then
    echo "Adding exploit components..."
    mkdir -p "$APP_BUNDLE_DIR/exploits"
    cp -R src/exploits/* "$APP_BUNDLE_DIR/exploits/"
fi

echo "Build completed successfully!"
