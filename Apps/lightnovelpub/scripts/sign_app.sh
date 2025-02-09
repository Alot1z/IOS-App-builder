#!/bin/bash

# App signing script for LightNovel Pub iOS app
# Supports iOS 16.0-17.0

set -e

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --app) APP_PATH="$2"; shift ;;
        --entitlements) ENTITLEMENTS_PATH="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate input
if [ ! -d "$APP_PATH" ]; then
    echo "Error: App bundle not found: $APP_PATH"
    exit 1
fi

if [ ! -f "$ENTITLEMENTS_PATH" ]; then
    echo "Error: Entitlements file not found: $ENTITLEMENTS_PATH"
    exit 1
fi

# Find the executable
APP_BINARY="$APP_PATH/$(basename "$APP_PATH" .app)"
if [ ! -f "$APP_BINARY" ]; then
    echo "Error: App binary not found: $APP_BINARY"
    exit 1
fi

# Sign frameworks and dylibs if they exist
find "$APP_PATH" -type f \( -name "*.framework" -o -name "*.dylib" \) -exec ldid -S {} \;

# Sign the main binary with entitlements
echo "Signing $APP_BINARY with entitlements..."
ldid -S"$ENTITLEMENTS_PATH" "$APP_BINARY"

# Verify signature
if [ -f "$APP_BINARY" ]; then
    echo "Successfully signed app bundle"
else
    echo "Error: Failed to sign app bundle"
    exit 1
fi
