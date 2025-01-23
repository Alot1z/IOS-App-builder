# TrollStore Enhanced

An enhanced version of TrollStore with additional features, improved build tools, and extended functionality.

## Core Features & Capabilities

### 1. Enhanced Build System
- Custom build tools in `bins/` directory
- Optimized compilation process
- Improved dependency management
- Streamlined build workflow

### 2. Extended Functionality
- Additional extensions in `extensions/` directory
- Improved app management
- Enhanced persistence methods
- Advanced configuration options

### 3. Improved Documentation
- Separate installation guides for different scenarios
- Clear step-by-step instructions
- Device-specific documentation
- Troubleshooting guides

## Installation Guides

For better organization and clarity, installation instructions are split into separate files based on your device and iOS version:

- [SSH Ramdisk Installation](install_sshrd.md) - For checkm8/arm64 devices
- [TrollHelper Installation](install_trollhelper.md) - For jailbroken devices
- [TrollHelperOTA arm64e Installation](install_trollhelperota_arm64e.md) - For A12-A15 devices
- [TrollHelperOTA iOS 15 Installation](install_trollhelperota_ios15.md) - For iOS 15 devices

## Project Structure

This enhanced version of TrollStore includes:

- `TrollStore/` - Original TrollStore (as git submodule)
- `bins/` - Enhanced build tools and utilities
- `extensions/` - Additional features and improvements
- Separate installation guides for different scenarios

## Build Configuration

### Requirements
- macOS/Linux build system
- Theos installed
- iOS SDK 16.2+
- ldid utility
- libarchive

### Build Process
```bash
# Set environment
export THEOS=/opt/theos
export SDKVERSION=16.2
export SYSROOT=/opt/theos/sdks/iPhoneOS16.2.sdk

# Build package
make package FINALPACKAGE=1
```

## Credits & Acknowledgments
- Original TrollStore by @opa334
- Enhanced build tools and extensions by Alot1z

## Version History
- 1.0.0: Initial enhanced version with improved build tools
- 1.0.1: Added extension support
- 1.0.2: Improved documentation and guides

## License
This project is licensed under the same terms as the original TrollStore.
