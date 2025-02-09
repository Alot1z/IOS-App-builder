#!/bin/bash

# Exit on error
set -e

# Set default SDK paths for Windows
XCODE_PATH="C:/Program Files/Xcode.app"
SDKROOT="$XCODE_PATH/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS17.5.sdk"
SWIFT_PATH="C:/Program Files/Swift/bin"
IMAGEMAGICK_PATH="C:/Program Files/ImageMagick-7.1.1-Q16-HDRI"

# Validate tools exist
if [ ! -f "$SWIFT_PATH/swiftc.exe" ]; then
    echo "Error: Swift compiler not found at $SWIFT_PATH/swiftc.exe"
    exit 1
fi

if [ ! -f "$IMAGEMAGICK_PATH/magick.exe" ]; then
    echo "Error: ImageMagick not found at $IMAGEMAGICK_PATH/magick.exe"
    exit 1
fi

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
required_args=(ios_version app_version min_ios_version max_ios_version optimization_level enable_bitcode enable_arc deployment_target build_type root_enabled exploit_enabled)
for arg in "${required_args[@]}"; do
    if [ -z "${!arg}" ]; then
        echo "Missing required argument: $arg"
        exit 1
    fi
done

# Convert paths to Windows format
CURRENT_DIR=$(pwd -W)
BUILD_DIR="$CURRENT_DIR/build"
BUILD_DIR=${BUILD_DIR//\//\\}

# Set up build directories
echo "Setting up build directories..."
mkdir -p "$BUILD_DIR"/{release,debug-symbols,logs}

# Generate icons using full ImageMagick path
"$IMAGEMAGICK_PATH/magick.exe" convert -version
if [ $? -ne 0 ]; then
    echo "Error: ImageMagick not working properly"
    exit 1
fi

# Generate icons
echo "Generating icons..."
"$CURRENT_DIR/scripts/generate_icons.sh"

# Find Swift files
SWIFT_FILES=()
while IFS= read -r -d '' file; do
    SWIFT_FILES+=("$file")
done < <(find "src" -name "*.swift" -print0)

echo "Found Swift files: ${SWIFT_FILES[*]}"

# Set up compiler flags
COMPILE_FLAGS=(
    "-sdk" "$SDKROOT"
    "-target" "arm64-apple-ios$min_ios_version"
    "-swift-version" "5"
)

# Add framework search paths
FRAMEWORK_SEARCH_PATHS=(
    "$SDKROOT/System/Library/Frameworks"
    "$SDKROOT/System/Library/PrivateFrameworks"
)

for path in "${FRAMEWORK_SEARCH_PATHS[@]}"; do
    COMPILE_FLAGS+=("-F" "$path")
done

# Add required frameworks
FRAMEWORKS=(
    "UIKit"
    "WebKit"
    "SafariServices"
    "UserNotifications"
    "SwiftUI"
)

for framework in "${FRAMEWORKS[@]}"; do
    COMPILE_FLAGS+=("-framework" "$framework")
done

# Add optimization flags
case $optimization_level in
    0)
        COMPILE_FLAGS+=("-Onone")
        ;;
    1|2|3)
        COMPILE_FLAGS+=("-O")
        ;;
    *)
        echo "Invalid optimization level: $optimization_level"
        exit 1
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

# Set minimum deployment target
COMPILE_FLAGS+=("-minimum-deployment-target" "ios$deployment_target")

# Add debug symbols for non-release builds
if [ "$build_type" != "release" ]; then
    COMPILE_FLAGS+=("-g")
fi

# Generate Info.plist
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
    <string>${app_version}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>MinimumOSVersion</key>
    <string>${min_ios_version}</string>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <true/>
</dict>
</plist>
EOF

echo "Generated Info.plist at $BUILD_DIR\\Info.plist"

# Build the app using full Swift path
echo "Building app..."
"$SWIFT_PATH/swiftc.exe" "${COMPILE_FLAGS[@]}" "${SWIFT_FILES[@]}" -o "$BUILD_DIR\\release\\LightNovelPub.exe" 2> "$BUILD_DIR\\logs\\build.log"

if [ $? -ne 0 ]; then
    echo "Build failed. Check $BUILD_DIR\\logs\\build.log for details."
    exit 1
fi

# Create IPA structure
echo "Creating IPA..."
mkdir -p "$BUILD_DIR\\Payload\\LightNovelPub.app"
cp "$BUILD_DIR\\release\\LightNovelPub.exe" "$BUILD_DIR\\Payload\\LightNovelPub.app\\"
cp "$BUILD_DIR\\Info.plist" "$BUILD_DIR\\Payload\\LightNovelPub.app\\"
cp -r "$BUILD_DIR\\Assets.xcassets" "$BUILD_DIR\\Payload\\LightNovelPub.app\\"

# Create IPA using PowerShell for better Windows compatibility
echo "Creating IPA archive..."
powershell.exe -Command "Compress-Archive -Path \"$BUILD_DIR\\Payload\" -DestinationPath \"$BUILD_DIR\\LightNovelPub.ipa\" -Force"

echo "Build complete! IPA created at $BUILD_DIR\\LightNovelPub.ipa"
