#!/bin/bash

set -e

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --bundle-id) bundle_id="$2"; shift ;;
        --app-name) app_name="$2"; shift ;;
        --app-version) app_version="$2"; shift ;;
        --min-ios-version) min_ios_version="$2"; shift ;;
        --max-ios-version) max_ios_version="$2"; shift ;;
        --output) output="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate required parameters
if [ -z "$bundle_id" ] || [ -z "$app_name" ] || [ -z "$app_version" ] || [ -z "$min_ios_version" ] || [ -z "$output" ]; then
    echo "Missing required parameters"
    echo "Usage: $0 --bundle-id <id> --app-name <name> --app-version <version> --min-ios-version <version> --output <file>"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$output")"

# Generate Info.plist
cat > "$output" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>${app_name}</string>
    <key>CFBundleExecutable</key>
    <string>LightNovelPub</string>
    <key>CFBundleIdentifier</key>
    <string>${bundle_id}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${app_name}</string>
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
    <key>UIDeviceFamily</key>
    <array>
        <integer>1</integer>
        <integer>2</integer>
    </array>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
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
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
EOF

echo "Generated Info.plist at $output"
