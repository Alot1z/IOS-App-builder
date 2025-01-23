# TrollStore Enhanced

An enhanced version of TrollStore with advanced iOS system integration and security bypass capabilities.

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

## Technical Implementation

### 1. Core System Integration
#### Kernel-Level Operations
- **AMFI Bypass System**
  - Custom signature validation hooking
  - Dynamic code signing verification bypass
  - Runtime entitlement injection
  - Kernel memory patch persistence

#### Process Management
- **Enhanced Process Control**
  - Custom process spawning mechanism
  - Elevated privilege management
  - System service integration
  - Background task handling

#### File System Integration
- **Protected Storage Access**
  - Custom container creation
  - System path manipulation
  - Secure file operations
  - Persistent data storage

### 2. Security Implementation

#### Certificate Management
- **Dynamic Certificate Handling**
  - Runtime certificate generation
  - Trust chain modification
  - Certificate validation bypass
  - Signature requirement nullification

#### Entitlement System
- **Advanced Entitlement Control**
  - Dynamic entitlement injection
  - System capability expansion
  - Permission elevation
  - Security policy modification

#### Sandbox Manipulation
- **Container Isolation Control**
  - Sandbox boundary modification
  - Inter-process communication enhancement
  - File system access expansion
  - Network restriction bypass

### 3. Enhanced Functionality

#### App Installation System
- **Advanced Installation Engine**
  - Custom IPA processing
  - Binary modification engine
  - Resource repackaging
  - Installation validation

#### Persistence Mechanism
- **System Integration Layer**
  - Boot persistence handling
  - System service integration
  - Update survival system
  - Recovery mechanism

#### Process Injection
- **Dynamic Code Execution**
  - Runtime library injection
  - Method swizzling engine
  - Hook management system
  - Dynamic patching

## Technical Architecture

### System Components

```plaintext
TrollStore Enhanced
├── Core System
│   ├── AMFI Bypass Engine
│   ├── Process Manager
│   └── FileSystem Controller
├── Security Layer
│   ├── Certificate Handler
│   ├── Entitlement Manager
│   └── Sandbox Controller
└── Enhancement Modules
    ├── Installation Engine
    ├── Persistence Manager
    └── Injection System
```

### Data Flow Architecture

```plaintext
User Input → Installation Request
↓
Installation Engine
├── IPA Processing
├── Binary Modification
└── Resource Repackaging
↓
Security Layer
├── Certificate Generation
├── Entitlement Injection
└── Sandbox Modification
↓
Core System
├── AMFI Bypass
├── Process Spawning
└── FileSystem Integration
↓
iOS System Integration
```

## Technical Specifications

### System Requirements
- **Device Architecture**: arm64/arm64e
- **iOS Version Support**: iOS 14.0-16.x
- **Minimum Storage**: 50MB
- **RAM Usage**: ~100MB during operation

### Security Features
- **Certificate Handling**:
  - Custom CA certificate generation
  - Trust chain manipulation
  - Signature validation bypass

- **Entitlement Management**:
  - Dynamic entitlement injection
  - System capability expansion
  - Permission elevation

- **Sandbox Control**:
  - Container isolation modification
  - IPC enhancement
  - FileSystem access control

### Performance Optimizations
- **Memory Management**:
  - Dynamic memory allocation
  - Resource usage optimization
  - Cache management system

- **Process Handling**:
  - Efficient process spawning
  - Background task optimization
  - System service integration

## Advanced Build Configuration

### Environment Variables
```bash
# Core Build Settings
THEOS=/opt/theos                  # Theos installation path
THEOS_DEVICE_IP=127.0.0.1        # Device IP for remote installation
THEOS_DEVICE_PORT=22             # SSH port for device connection
THEOS_PACKAGE_SCHEME=rootless    # Package scheme (rootless/rooted)

# Build Type Options
FINALPACKAGE=1                   # Enable release mode optimizations
DEBUG=0                          # Disable debug symbols (set 1 for debugging)
STRIP=1                          # Strip binary (reduces size)

# Custom Paths
TROLLSTORE_APP_PATH=/var/containers/Bundle/Application/AppUUID
TROLLSTORE_APP_GROUP=group.com.example.app
```

### Build Types

#### Debug Build
```bash
make package DEBUG=1 FINALPACKAGE=0
```
- Includes debug symbols
- Enables verbose logging
- Disables optimizations
- Useful for development

#### Release Build
```bash
make package FINALPACKAGE=1 STRIP=1
```
- Optimized for size and performance
- Strips debug symbols
- Enables all optimizations
- Ready for distribution

### Automated Build System

Our GitHub Actions workflow provides:

#### 1. Continuous Integration
- Automatic builds on push/PR
- Code analysis and testing
- Build artifact generation
- Automated releases

#### 2. Build Artifacts
- Compiled .deb packages
- SHA256 checksums
- Version information
- Build date stamps

#### 3. Quality Control
- Xcode analysis
- Code signing verification
- Dependency validation
- Build environment checks

## Installation Guides

For better organization and clarity, installation instructions are split into separate files based on your device and iOS version:

- [SSH Ramdisk Installation](install_sshrd.md) - For checkm8/arm64 devices
- [TrollHelper Installation](install_trollhelper.md) - For jailbroken devices
- [TrollHelperOTA arm64e Installation](install_trollhelperota_arm64e.md) - For A12-A15 devices
- [TrollHelperOTA iOS 15 Installation](install_trollhelperota_ios15.md) - For iOS 15 devices

## Installation Methods

### 1. TrollHelper Method
- **Technical Process**:
  1. Binary injection into helper app
  2. System service registration
  3. Persistence setup
  4. Certificate installation

### 2. SSH Ramdisk Method
- **Technical Implementation**:
  1. Custom ramdisk creation
  2. System mount modification
  3. Binary deployment
  4. Boot process integration

### 3. OTA Installation
- **System Integration**:
  1. URL scheme registration
  2. Installation validation
  3. System service setup
  4. Persistence mechanism

## Advanced Usage

### Custom Binary Installation
```objc
// Example of custom binary installation
TSInstallationManager *manager = [TSInstallationManager sharedInstance];
[manager installBinaryWithPath:@"/path/to/binary"
                  permissions:0755
                  persistent:YES
                  completion:^(BOOL success, NSError *error) {
    if (success) {
        // Binary installed successfully
    }
}];
```

### Entitlement Injection
```objc
// Example of entitlement injection
TSEntitlementManager *entManager = [TSEntitlementManager sharedInstance];
[entManager injectEntitlements:@{
    @"com.apple.private.security.no-sandbox": @YES,
    @"platform-application": @YES
} forBinaryAtPath:@"/path/to/binary"];
```

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

## Development Guide

### 1. Setting Up Development Environment
```bash
# Install dependencies
brew install ldid make theos dpkg xz

# Clone repository with submodules
git clone --recursive https://github.com/Alot1z/TrollStore_Enhanced.git
cd TrollStore_Enhanced

# Initialize build environment
./bins/build.sh init
```

### 2. Making Changes
1. Create a new branch
2. Make your changes
3. Test locally
4. Create pull request

### 3. Testing
- Run local tests: `make test`
- Check code style: `make lint`
- Verify build: `make package DEBUG=1`

## Credits & Acknowledgments
- Original TrollStore by @opa334
- Enhanced build tools and extensions by Alot1z

## Version History
- 1.0.0: Initial enhanced version with improved build tools
- 1.0.1: Added extension support
- 1.0.2: Improved documentation and guides
- 1.0.3: Added automated build system and environment controls

## License
This project is licensed under the same terms as the original TrollStore.
