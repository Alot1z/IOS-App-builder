# LightNovel Pub iOS App

A native iOS app for reading light novels from lightnovelpub.com, with enhanced features and TrollStore compatibility.

## Features

- Native iOS UI with large titles and modern design
- Pull-to-refresh support
- Progress tracking
- Navigation toolbar
- Reader mode with customizable text size
- Download manager (coming soon)
- Theme settings (coming soon)
- Share functionality
- Cache management

## Building

1. Ensure you have the following installed:
   - Xcode Command Line Tools
   - ImageMagick
   - ldid

2. Run the build script:
   ```bash
   ./scripts/build.sh --ios-version 17.0 --app-version 1.0.0
   ```

3. The IPA will be generated in the `build` directory

## Installing

1. Install TrollStore on your iOS device
2. Copy the IPA to your device
3. Open in TrollStore and install

## Directory Structure

```
.
├── build/              # Build output directory
├── resources/          # App resources (icons, launch screen, etc.)
├── scripts/           # Build scripts
│   ├── build.sh       # Main build script
│   ├── create_plist.sh # Creates Info.plist
│   ├── generate_icons.sh # Generates app icons
│   └── sign_app.sh    # Signs app with TrollStore entitlements
└── src/               # Swift source files
    ├── AppDelegate.swift
    └── MainViewController.swift
```

## Development

The app is built using Swift and UIKit, with WKWebView for web content. It's designed to be easily extensible with new features.
