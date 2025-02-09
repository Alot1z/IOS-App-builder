#!/bin/bash

# Exit on any error
set -euo pipefail
IFS=$'\n\t'

# Validate environment
command -v "C:/Program Files/ImageMagick-7.1.1-Q16-HDRI/magick.exe" >/dev/null 2>&1 || { echo "ImageMagick required but not installed. Aborting." >&2; exit 1; }
command -v "C:/Program Files/Swift/bin/swiftc.exe" >/dev/null 2>&1 || { echo "Swift compiler required but not installed. Aborting." >&2; exit 1; }

# Default paths
XCODE_PATH="C:/Program Files/Xcode.app"
SDKROOT="$XCODE_PATH/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.5.sdk"
SWIFT_PATH="C:/Program Files/Swift/bin"
IMAGEMAGICK_PATH="C:/Program Files/ImageMagick-7.1.1-Q16-HDRI"

# Parse and validate arguments with defaults
declare -A ARGS=(
    [ios_version]=""
    [app_version]=""
    [min_ios_version]=""
    [max_ios_version]=""
    [optimization_level]="3"
    [enable_bitcode]="false"
    [enable_arc]="true"
    [deployment_target]=""
    [build_type]="release"
    [root_enabled]="false"
    [exploit_enabled]="false"
)

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --ios-version) ARGS[ios_version]="$2"; shift 2 ;;
        --app-version) ARGS[app_version]="$2"; shift 2 ;;
        --min-ios-version) ARGS[min_ios_version]="$2"; shift 2 ;;
        --max-ios-version) ARGS[max_ios_version]="$2"; shift 2 ;;
        --optimization-level) ARGS[optimization_level]="$2"; shift 2 ;;
        --enable-bitcode) ARGS[enable_bitcode]="$2"; shift 2 ;;
        --enable-arc) ARGS[enable_arc]="$2"; shift 2 ;;
        --deployment-target) ARGS[deployment_target]="$2"; shift 2 ;;
        --build-type) ARGS[build_type]="$2"; shift 2 ;;
        --root-enabled) ARGS[root_enabled]="$2"; shift 2 ;;
        --exploit-enabled) ARGS[exploit_enabled]="$2"; shift 2 ;;
        *) echo "Unknown parameter: $1" >&2; exit 1 ;;
    esac
done

# Validate required arguments
for key in "${!ARGS[@]}"; do
    if [[ -z "${ARGS[$key]}" ]]; then
        echo "Missing required argument: --$key" >&2
        exit 1
    fi
done

# Validate version numbers
version_regex="^[0-9]+\.[0-9]+(\.[0-9]+)?$"
for version in ios_version app_version min_ios_version max_ios_version deployment_target; do
    if [[ ! "${ARGS[$version]}" =~ $version_regex ]]; then
        echo "Invalid version format for --$version: ${ARGS[$version]}" >&2
        exit 1
    fi
done

# Validate optimization level
if [[ ! "${ARGS[optimization_level]}" =~ ^[0-3]$ ]]; then
    echo "Invalid optimization level: ${ARGS[optimization_level]}" >&2
    exit 1
fi

# Convert paths to Windows format
CURRENT_DIR=$(pwd -W)
BUILD_DIR="$CURRENT_DIR/build"
BUILD_DIR=${BUILD_DIR//\//\\}

# Create clean build directories
echo "Setting up build directories..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"/{release,debug-symbols,logs,DerivedData/{Build/Intermediates.noindex,Build/Products}}

# Generate icons with error checking
echo "Generating icons..."
"$CURRENT_DIR/scripts/generate_icons.sh" || {
    echo "Icon generation failed" >&2
    exit 1
}

# Find and validate Swift files
mapfile -t SWIFT_FILES < <(find "src" -name "*.swift" -type f -print0 | xargs -0)
if [ ${#SWIFT_FILES[@]} -eq 0 ]; then
    echo "No Swift source files found" >&2
    exit 1
fi

echo "Found Swift files: ${SWIFT_FILES[*]}"

# Set up compiler flags
COMPILE_FLAGS=(
    "-sdk" "$SDKROOT"
    "-target" "arm64-apple-ios${ARGS[min_ios_version]}"
    "-swift-version" "5"
)

# Add framework search paths
FRAMEWORK_PATHS=(
    "$SDKROOT/System/Library/Frameworks"
    "$SDKROOT/System/Library/PrivateFrameworks"
)

for path in "${FRAMEWORK_PATHS[@]}"; do
    COMPILE_FLAGS+=("-F" "$path")
done

# Add required frameworks with validation
FRAMEWORKS=(
    "UIKit"
    "WebKit"
    "SafariServices"
    "UserNotifications"
    "SwiftUI"
    "CoreData"
    "CoreGraphics"
    "CoreText"
    "QuartzCore"
    "Metal"
    "MetalKit"
)

for framework in "${FRAMEWORKS[@]}"; do
    if [ -d "$SDKROOT/System/Library/Frameworks/$framework.framework" ]; then
        COMPILE_FLAGS+=("-framework" "$framework")
    else
        echo "Framework not found: $framework" >&2
        exit 1
    fi
done

# Add optimization flags
case ${ARGS[optimization_level]} in
    0) COMPILE_FLAGS+=("-Onone") ;;
    1) COMPILE_FLAGS+=("-O") ;;
    2) COMPILE_FLAGS+=("-O") ;;
    3) COMPILE_FLAGS+=("-O" "-whole-module-optimization") ;;
    *) echo "Invalid optimization level" >&2; exit 1 ;;
esac

# Add ARC flag if enabled
if [ "${ARGS[enable_arc]}" = true ]; then
    COMPILE_FLAGS+=("-fobjc-arc")
fi

# Add bitcode flag if enabled
if [ "${ARGS[enable_bitcode]}" = true ]; then
    COMPILE_FLAGS+=("-embed-bitcode")
fi

# Set deployment target
COMPILE_FLAGS+=("-minimum-deployment-target" "ios${ARGS[deployment_target]}")

# Add debug symbols for non-release builds
if [ "${ARGS[build_type]}" != "release" ]; then
    COMPILE_FLAGS+=("-g")
fi

# Generate Info.plist with all required keys
cat > "$BUILD_DIR\\Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>LightNovelPub</string>
    <key>CFBundleIdentifier</key>
    <string>com.lightnovelpub.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>LightNovelPub</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${ARGS[app_version]}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>MinimumOSVersion</key>
    <string>${ARGS[min_ios_version]}</string>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
        <string>metal</string>
    </array>
    <key>UIStatusBarHidden</key>
    <true/>
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <true/>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
    </array>
    <key>ITSAppUsesNonExemptEncryption</key>
    <false/>
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>https</string>
        <string>http</string>
    </array>
</dict>
</plist>
EOF

echo "Generated Info.plist at $BUILD_DIR\\Info.plist"

# Build the app with error logging
echo "Building app..."
"$SWIFT_PATH/swiftc.exe" "${COMPILE_FLAGS[@]}" "${SWIFT_FILES[@]}" -o "$BUILD_DIR\\release\\LightNovelPub.exe" 2> "$BUILD_DIR\\logs\\build.log" || {
    echo "Build failed. Check $BUILD_DIR\\logs\\build.log for details." >&2
    exit 1
}

# Create IPA structure
echo "Creating IPA..."
mkdir -p "$BUILD_DIR\\Payload\\LightNovelPub.app"
cp "$BUILD_DIR\\release\\LightNovelPub.exe" "$BUILD_DIR\\Payload\\LightNovelPub.app\\"
cp "$BUILD_DIR\\Info.plist" "$BUILD_DIR\\Payload\\LightNovelPub.app\\"
cp -r "$BUILD_DIR\\Assets.xcassets" "$BUILD_DIR\\Payload\\LightNovelPub.app\\"

# Create IPA using PowerShell for better Windows compatibility
echo "Creating IPA archive..."
powershell.exe -Command "Compress-Archive -Path \"$BUILD_DIR\\Payload\" -DestinationPath \"$BUILD_DIR\\LightNovelPub.ipa\" -Force" || {
    echo "Failed to create IPA archive" >&2
    exit 1
}

# Verify IPA
if [ ! -f "$BUILD_DIR\\LightNovelPub.ipa" ]; then
    echo "IPA file not created successfully" >&2
    exit 1
fi

echo "Build complete! IPA created at $BUILD_DIR\\LightNovelPub.ipa"

# Clean up temporary files
rm -rf "$BUILD_DIR\\Payload"
rm -rf "$BUILD_DIR\\DerivedData\\Build\\Intermediates.noindex"

exit 0
