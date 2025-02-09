#!/bin/bash

# Script to integrate root access into iOS apps
# Based on Sileo's giveMeRoot implementation

set -e

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --app-dir) APP_DIR="$2"; shift ;;
        --bundle-id) BUNDLE_ID="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Validate input
if [ ! -d "$APP_DIR" ]; then
    echo "Error: App directory not found: $APP_DIR"
    exit 1
fi

TOOLS_DIR="$(dirname "$0")"
ROOT_SRC="$TOOLS_DIR/giveMeRoot.m"
ROOT_ENTITLEMENTS="$TOOLS_DIR/root_entitlements.plist"

# Copy root source to app
cp "$ROOT_SRC" "$APP_DIR/src/RootHelper.m"

# Merge root entitlements with app entitlements
if [ -f "$APP_DIR/entitlements.plist" ]; then
    MERGED_ENTITLEMENTS="$APP_DIR/entitlements_merged.plist"
    plutil -create xml1 "$MERGED_ENTITLEMENTS"
    
    # Copy existing entitlements
    plutil -extract . xml1 "$APP_DIR/entitlements.plist" -o "$MERGED_ENTITLEMENTS"
    
    # Add root entitlements
    while IFS= read -r line; do
        if [[ $line =~ "<key>(.*)</key>" ]]; then
            key="${BASH_REMATCH[1]}"
            plutil -extract "$key" xml1 "$ROOT_ENTITLEMENTS" -o - >> "$MERGED_ENTITLEMENTS"
        fi
    done < "$ROOT_ENTITLEMENTS"
    
    mv "$MERGED_ENTITLEMENTS" "$APP_DIR/entitlements.plist"
fi

# Update build.yml to include root source
echo "
# Root access integration
root_source:
  - src/RootHelper.m
root_frameworks:
  - Foundation
  - UIKit
" >> "$APP_DIR/build.yml"

# Add root initialization to AppDelegate
if [ -f "$APP_DIR/src/AppDelegate.swift" ]; then
    TEMP_FILE="$APP_DIR/src/AppDelegate.swift.tmp"
    awk '
        /import UIKit/ { print; print "import Foundation"; next }
        /class AppDelegate/ { 
            print;
            print "    private let rootHelper = RootHelper()";
            print "    ";
            next
        }
        /func application.*didFinishLaunchingWithOptions/ {
            print;
            print "        // Initialize root access";
            print "        if RootHelper.gainRoot() == 0 {";
            print "            print(\"Root access granted\")";
            print "        } else {";
            print "            print(\"Failed to gain root access\")";
            print "        }";
            next
        }
        { print }
    ' "$APP_DIR/src/AppDelegate.swift" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$APP_DIR/src/AppDelegate.swift"
fi

echo "Root access integration complete for $APP_DIR"
