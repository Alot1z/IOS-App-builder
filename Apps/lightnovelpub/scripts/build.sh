#!/bin/bash

# Exit on error
set -e

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --ios-version)
            ios_version="$2"
            shift 2
            ;;
        --app-version)
            app_version="$2"
            shift 2
            ;;
        --min-ios-version)
            min_ios_version="$2"
            shift 2
            ;;
        --max-ios-version)
            max_ios_version="$2"
            shift 2
            ;;
        --optimization-level)
            optimization_level="$2"
            shift 2
            ;;
        --enable-bitcode)
            enable_bitcode="$2"
            shift 2
            ;;
        --enable-arc)
            enable_arc="$2"
            shift 2
            ;;
        --deployment-target)
            deployment_target="$2"
            shift 2
            ;;
        --build-type)
            build_type="$2"
            shift 2
            ;;
        --root-enabled)
            root_enabled="$2"
            shift 2
            ;;
        --exploit-enabled)
            exploit_enabled="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$SDKROOT" ]; then
    SDKROOT="/Applications/Xcode_15.4.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.5.sdk"
fi

if [ -z "$ios_version" ]; then
    ios_version="17.0"
fi

if [ -z "$min_ios_version" ]; then
    min_ios_version="16.0"
fi

if [ -z "$max_ios_version" ]; then
    max_ios_version="17.0"
fi

# Setup build directories
echo "Setting up build directories..."
BUILD_DIR="build"
DERIVED_DATA_DIR="build/DerivedData"
INTERMEDIATE_DIR="build/DerivedData/Build/Intermediates.noindex"
PRODUCTS_DIR="build/DerivedData/Build/Products"
LOGS_DIR="build/logs"
DEBUG_SYMBOLS_DIR="build/debug-symbols"
ROOT_DIR="build/root"
EXPLOITS_DIR="build/exploits"

for dir in "$BUILD_DIR" "$DERIVED_DATA_DIR" "$INTERMEDIATE_DIR" "$PRODUCTS_DIR" "$LOGS_DIR" "$DEBUG_SYMBOLS_DIR" "$ROOT_DIR" "$EXPLOITS_DIR"; do
    mkdir -p "$dir"
    chmod 755 "$dir"
    if [ ! -d "$dir" ]; then
        echo "Created directory: $dir"
    fi
done

# Generate app icons
if [ -f "scripts/generate_icons.sh" ]; then
    chmod +x scripts/generate_icons.sh
    ./scripts/generate_icons.sh assets/icon.png
fi

# Find Swift files
SWIFT_FILES=(src/*.swift)
echo "Found Swift files: ${SWIFT_FILES[*]}"

# Set up compiler flags
COMPILE_FLAGS=(
    "-sdk" "$SDKROOT"
    "-target" "arm64-apple-ios$min_ios_version"
    "-F" "$FRAMEWORK_SEARCH_PATHS"
)

# Add optimization flags
case $optimization_level in
    0)
        COMPILE_FLAGS+=("-Onone")
        ;;
    1)
        COMPILE_FLAGS+=("-O")
        ;;
    2)
        COMPILE_FLAGS+=("-O")
        ;;
    3|*)
        COMPILE_FLAGS+=("-O")
        ;;
esac

# Add ARC flag if enabled
if [ "$enable_arc" = true ]; then
    COMPILE_FLAGS+=("-fobjc-arc")
fi

# Add bitcode flag if enabled
if [ "$enable_bitcode" = true ]; then
    COMPILE_FLAGS+=("-fembed-bitcode")
fi

# Set deployment target
COMPILE_FLAGS+=("-target-variant" "ios$deployment_target")

# Build the app
echo "Found Swift files: $SWIFT_FILES"
swiftc "${COMPILE_FLAGS[@]}" $SWIFT_FILES -o "$BUILD_DIR/LightNovelPub"

# Create IPA structure
mkdir -p "build/Payload/LightNovelPub.app"
cp "$BUILD_DIR/LightNovelPub" "build/Payload/LightNovelPub.app/"
cp "build/Info.plist" "build/Payload/LightNovelPub.app/"
cp -r "build/Assets.xcassets" "build/Payload/LightNovelPub.app/"

# Copy root/exploit files if enabled
if [ "$root_enabled" = true ]; then
    mkdir -p "build/Payload/LightNovelPub.app/root"
    cp -r "root/" "build/Payload/LightNovelPub.app/root/"
fi

if [ "$exploit_enabled" = true ]; then
    mkdir -p "build/Payload/LightNovelPub.app/exploits"
    cp -r "exploits/" "build/Payload/LightNovelPub.app/exploits/"
fi

# Create IPA
cd build
zip -r "LightNovelPub.ipa" "Payload"
cd ..

echo "Build complete! IPA file created at build/LightNovelPub.ipa"
