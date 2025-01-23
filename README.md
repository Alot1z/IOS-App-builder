# TrollStore Enhanced

A powerful iOS application installer that bypasses Apple's restrictions, providing advanced capabilities for iOS 17.0 and above. This enhanced version includes new exploits, improved features, and extended functionality.

## Core Features & Capabilities

### 1. Advanced Installation System
- Persistent App Installation: Apps remain installed through reboots
- Custom IPA Support: Install any compatible IPA file
- URL Installation: Direct install via URL scheme
- Bulk Installation: Install multiple apps simultaneously

### 2. Enhanced Security Bypass
- CoreTrust Bypass: Utilizing multiple exploit chains
- Certificate Validation: Bypasses Apple's signature requirements
- Entitlement Management: Custom entitlement injection
- Root Access: Controlled root helper functionality

### 3. Exploit Chain Integration

#### Primary Exploit (CVE-2023-42824)
- Kernel Memory Manipulation
- Process Injection Capabilities
- Root Permission Escalation
- iOS 17.0-17.1.1 Support
- Advanced MACF Policy Bypass

#### Secondary Exploit (CVE-2023-41991)
- Alternative Exploitation Path
- Enhanced Stability
- iOS 17.0-17.2 Support
- Sandbox Escape Functionality
- Process Integrity Validation Bypass

### 4. Advanced Features

#### URL Scheme Support
```
apple-magnifier://install?url=<URL_to_IPA>
apple-magnifier://enable-jit?bundle-id=<Bundle_ID>
```

#### Persistence Helper System
- System App Integration
- Icon Cache Management
- Automatic Reregistration
- Persistence Through Updates

#### Root Helper Functionality
- Privileged Operations Support
- Custom Binary Execution
- System Level Modifications
- Protected Resource Access

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

## Advanced Configuration

### Entitlements Management

Available entitlements for customization:
```xml
<!-- Root Access -->
<key>com.apple.private.security.container-required</key>
<false/>

<!-- Sandbox Escape -->
<key>com.apple.private.security.no-sandbox</key>
<true/>

<!-- Platform Application -->
<key>platform-application</key>
<true/>

<!-- Root Helper -->
<key>com.apple.private.persona-mgmt</key>
<true/>
```

### Known Limitations
- No TF_PLATFORM support
- Cannot spawn launch daemons
- Limited process injection capabilities
- No CS_PLATFORMIZED support

## Advanced App Environment Features

### 1. Dynamic Environment Control

#### Real-Time Variable Management
- Live Environment Editing
- Persistent Changes
- Variable Templates
- Import/Export Configurations

#### System Integration Example
```bash
# Example environment configuration
DYLD_INSERT_LIBRARIES=/path/to/tweak.dylib
TROLLSTORE_APP_PATH=/var/containers/Bundle/Application/AppUUID
TROLLSTORE_APP_GROUP=group.com.example.app
```

### 2. Advanced App Modifications

#### Memory Management
```bash
# Memory configuration example
TROLLSTORE_MEMORY_LIMIT=8192        # 8GB RAM limit
TROLLSTORE_JETSAM_PRIORITY=1        # High priority
TROLLSTORE_VM_EXTENDED=1            # Enable extended virtual memory
```

#### Process Control
```bash
# Process control configuration
TROLLSTORE_BACKGROUND_MODE=unlimited
TROLLSTORE_CPU_PRIORITY=80          # 0-100 scale
TROLLSTORE_THREAD_LIMIT=64          # Maximum thread count
```

### 3. Enhanced Security Controls

#### App Sandbox Configuration
```xml
<!-- Advanced sandbox configuration -->
<key>com.apple.private.security.sandbox.override</key>
<dict>
    <key>file-access</key>
    <array>
        <string>/private/var/mobile/</string>
        <string>/var/mobile/Media/</string>
    </array>
    <key>network-access</key>
    <true/>
</dict>
```

## Debugging & Troubleshooting

### Debug Logging
Enable advanced logging in Settings:
1. Open TrollStore
2. Go to Settings > Advanced
3. Enable Debug Logging
4. View logs in `/var/log/trollstore.log`

### Common Issues
- Installation Fails
  - Verify iOS version compatibility
  - Check available storage
  - Ensure network connectivity
- Apps Crash on Launch
  - Verify entitlements configuration
  - Check for banned entitlements
  - Validate binary signatures
- Persistence Issues
  - Reinstall persistence helper
  - Verify system app status
  - Check icon cache status

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
- CoreTrust bug by @alfiecg_dev
- Google TAG - Original vulnerability discovery
- @LinusHenze - installd bypass

## Version History
- 2.0.0: Initial iOS 17 support
- 2.0.1: Added CVE-2023-42824
- 2.0.2: Integrated CVE-2023-41991
- 2.0.3: Enhanced persistence system

## License
This project is licensed under the same terms as the original TrollStore.
