# iOS App Builder Tools

This directory contains shared tools and utilities used by all apps in the iOS App Builder project.

## Directory Structure

```
tools/
├── bin/           # Binary executables (ldid, choma, unzip)
├── scripts/       # Shared build and helper scripts
└── config/        # Configuration files for tools
```

## Tools Description

### Binary Tools (bin/)
- `ldid`: Code signing tool for iOS apps
- `choma`: iOS app manipulation tool
- `unzip`: Archive extraction tool

### Scripts (scripts/)
- `build.sh`: Main build script for iOS apps
- `build_enhanced.sh`: Enhanced build script with additional features
- `debug_helper.sh`: Helper script for debugging builds

### Configuration (config/)
- `tools_config.plist`: Configuration settings for build tools

## Usage

Each app in the `Apps` directory can use these shared tools by referencing them in their build scripts. For example:

```bash
"$TOOLS_DIR/bin/ldid" -S entitlements.plist "$APP_PATH"
```

Make sure to set the `TOOLS_DIR` environment variable to point to this directory in your build scripts.
