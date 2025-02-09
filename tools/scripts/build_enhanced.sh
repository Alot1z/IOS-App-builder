#!/bin/bash

echo "🚀 Starting TrollStore build process..."

# Check for required tools
echo "🔍 Verifying build tools..."

# Check for ldid
if ! command -v ldid &> /dev/null; then
    echo "✗ Missing ldid"
    exit 1
else
    echo "✓ Found ldid"
fi

# Build and install insert_dylib
echo "📦 Building insert_dylib..."
git clone https://github.com/pwn20wndstuff/insert_dylib
cd insert_dylib
xcodebuild
sudo cp build/Release/insert_dylib /usr/local/bin/
cd ..
rm -rf insert_dylib

# Verify insert_dylib installation
if ! command -v insert_dylib &> /dev/null; then
    echo "✗ Failed to install insert_dylib"
    exit 1
else
    echo "✓ Found insert_dylib"
fi

# Build TrollStore
echo "🛠 Building TrollStore..."
make clean
make package FINALPACKAGE=1

# Sign the package
echo "📝 Signing package..."
cd packages
for deb in *.deb; do
    dpkg-deb -R "$deb" extracted
    mkdir -p Payload
    cp -r extracted/Applications/* Payload/ || true
    cp -r extracted/Library Payload/TrollStore.app/ || true
    
    # Insert dylib
    insert_dylib --all-yes "@executable_path/TrollStore" Payload/TrollStore.app/TrollStore
    
    # Create IPA
    zip -r "${deb%.*}.ipa" Payload
    rm -rf extracted Payload
    
    # Sign IPA
    ldid -S../entitlements.plist "${deb%.*}.ipa"
done

echo "✅ Build complete!"
