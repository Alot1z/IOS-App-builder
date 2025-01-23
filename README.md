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

## New Features in TrollStore App

### App Management Interface
#### Location: Main Tab > Installed Apps
- **Enhanced App List**
  - Shows all installed apps with new detailed info
  - Display app version, bundle ID, and environment status
  - New quick action buttons for each app

#### App Environment Editor
**Location: App Details > Environment Variables**
1. Tap any app in the list
2. Select "Edit Environment"
3. Add/Edit variables:
   ```
   DYLD_INSERT_LIBRARIES=/path/to/tweak.dylib
   TROLLSTORE_ENTITLEMENTS=1
   ```
4. Tap "Save" to store changes
5. **NEW**: Tap "Reinstall" button that appears after saving
   - This reregisters the app with new environment
   - Preserves app data while applying changes

### New Control Center
**Location: Settings Tab > Advanced Controls**
- **Process Manager**
  - View running processes
  - Force stop apps
  - Clear app cache
  - Reset app environment

- **Security Controls**
  - Manage entitlements
  - Toggle security features
  - Certificate management

### Enhanced Installation
**Location: Main Tab > "+" Button**
- **Multi-Source Install**
  - Local IPA files
  - Direct URL install
  - **NEW**: Bulk installation support
  
- **Installation Options**
  - Custom app name
  - Bundle ID modification
  - Environment preset selection

### Advanced Features
**Location: Settings > Advanced**
- **Persistence Helper**
  - Enhanced persistence options
  - Auto-respring settings
  - Update survival configuration

- **Root Helper**
  - Root access management
  - System modification tools
  - FileSystem access controls

### URL Scheme Support
**Usage: From Any App**
```
trollstore://install?url=<IPA_URL>
trollstore://settings/environment?bundle=<BUNDLE_ID>
```

## Using TrollStore Enhanced

### Main App Interface
![Main Interface](images/main_interface.png)

#### 1. App List View (Home Screen)
- **Top Bar**:
  - "+" button for new installations
  - Search bar for filtering apps
  - Sort options (Name, Date, Size)

- **App Cards**:
  - Shows app icon and name
  - Bundle ID and version
  - Environment status indicator
  - Quick action buttons:
    - Edit Environment
    - Reinstall
    - Delete
    - Share

#### 2. Environment Editor
![Environment Editor](images/env_editor.png)

1. **Access**:
   - Tap any app in the list
   - Select "Edit Environment"
   
2. **Available Options**:
   ```
   # Common Environment Variables
   DYLD_INSERT_LIBRARIES=/path/to/tweak.dylib
   TROLLSTORE_ENTITLEMENTS=1
   TROLLSTORE_PERSIST=1
   ```

3. **Using the Editor**:
   - Add/Remove variables with +/- buttons
   - Use presets from dropdown menu
   - Import/Export configurations
   
4. **Saving Changes**:
   - Tap "Save" to store configuration
   - **Important**: Tap "Reinstall" in the popup
   - Wait for app reregistration

#### 3. Advanced Controls
![Advanced Menu](images/advanced_menu.png)

- **Process Manager**:
  - List of running processes
  - Memory usage indicators
  - Force stop option
  - Cache clearing
  
- **Security Settings**:
  - Entitlement toggles
  - Root access controls
  - System integration options

### Installation Methods

#### 1. Local IPA Install
1. Tap "+" on main screen
2. Choose "Select IPA File"
3. Browse to your IPA
4. Configure options:
   - Custom name
   - Environment variables
   - Persistence settings
5. Tap "Install"

#### 2. URL Installation
1. Tap "+" on main screen
2. Choose "Install from URL"
3. Enter or paste IPA URL
4. Configure same options
5. Tap "Install"

#### 3. Bulk Installation
1. Tap "+" on main screen
2. Choose "Bulk Install"
3. Select multiple IPAs or URLs
4. Apply batch settings
5. Start installation

### Quick Tips
- **Save Button**: Always visible after changes
- **Reinstall Button**: Appears after saving
- **Persistence**: Enable in advanced settings
- **Backup**: Export configurations regularly

### Troubleshooting
1. **App Won't Launch After Environment Change**:
   - Go back to Environment Editor
   - Verify variables are correct
   - Try removing one variable at a time
   - Always use "Reinstall" after changes

2. **Environment Not Applying**:
   - Check if "Save" was tapped
   - Ensure "Reinstall" was done
   - Verify app is properly registered

3. **Installation Fails**:
   - Check URL/file validity
   - Verify enough storage
   - Try clearing TrollStore cache
   - Use "Advanced Install" option

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

- `TrollStore/` - Original TrollStore
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

## How New Features Are Integrated

### 1. Build Integration
When building TrollStore Enhanced, new features are compiled and integrated:

1. **Core Integration**
```bash
make package FINALPACKAGE=1
```
- Compiles new UI components
- Builds enhanced features
- Integrates with main TrollStore app

2. **Extension Building**
```bash
cd extensions
make package
```
- Creates feature modules
- Builds new functionality
- Prepares for integration

3. **Final Integration**
- All components are packaged into main .deb
- Features automatically integrate on installation
- No manual setup required

## Complete Environment Variables Reference

### 1. Public Variables (User-Configurable)
Safe to modify, intended for general use:

| Variable | Description | Default | Toggle |
|----------|-------------|---------|--------|
| `TROLLSTORE_PERSIST` | Keep app installed after reboot | 0 | ✓ |
| `TROLLSTORE_ENTITLEMENTS` | Enable all entitlements | 0 | ✓ |
| `TROLLSTORE_LOG_LEVEL` | Logging detail (0-4) | 1 | - |
| `TROLLSTORE_CONTAINER` | Custom container path | Default | - |
| `TROLLSTORE_BACKUP` | Enable automatic backups | 0 | ✓ |
| `TROLLSTORE_UPDATE_CHECK` | Auto-check for updates | 1 | ✓ |
| `TROLLSTORE_CACHE_DIR` | Custom cache directory | Default | - |
| `TROLLSTORE_TEMP_DIR` | Temporary file location | Default | - |
| `TROLLSTORE_NO_SANDBOX` | Disable app sandboxing | 0 | ✓ |
| `TROLLSTORE_DEBUG` | Enable debug logging | 0 | ✓ |

### 2. Private/System Variables
Core system variables - modify with caution:

| Variable | Description | Default | Toggle |
|----------|-------------|---------|--------|
| `DYLD_INSERT_LIBRARIES` | Load custom dylibs | Empty | ✓ |
| `TROLLSTORE_ROOT_PATH` | TrollStore installation path | System | - |
| `TROLLSTORE_APP_DATA` | App data storage location | System | - |
| `TROLLSTORE_ORIG_PATH` | Original binary path | System | - |
| `TROLLSTORE_HOOKS` | Custom hook libraries | Empty | ✓ |
| `TROLLSTORE_DAEMON` | Daemon configuration | Default | - |
| `TROLLSTORE_SIGNATURES` | Signature verification | 1 | ✓ |
| `TROLLSTORE_ENTITLEMENTS_ALL` | Grant all entitlements | 0 | ✓ |

### 3. Security Variables
Control app security and permissions:

| Variable | Description | Default | Toggle |
|----------|-------------|---------|--------|
| `TROLLSTORE_SECURITY_LEVEL` | Security enforcement level (0-3) | 2 | - |
| `TROLLSTORE_ALLOW_UNSIGNED` | Allow unsigned code execution | 0 | ✓ |
| `TROLLSTORE_SANDBOX_LEVEL` | Sandbox restriction level (0-3) | 2 | - |
| `TROLLSTORE_ENTITLEMENT_MASK` | Custom entitlement restrictions | Full | - |
| `TROLLSTORE_SECURE_STORAGE` | Enable encrypted storage | 1 | ✓ |
| `TROLLSTORE_KEYCHAIN_ACCESS` | Allow keychain access | 0 | ✓ |
| `TROLLSTORE_SECURE_BOOT` | Verify boot chain | 1 | ✓ |
| `TROLLSTORE_JIT_ALLOW` | Allow JIT compilation | 0 | ✓ |

### 4. Development Variables
For developers and debugging:

| Variable | Description | Default | Toggle |
|----------|-------------|---------|--------|
| `TROLLSTORE_DEV_MODE` | Enable developer features | 0 | ✓ |
| `TROLLSTORE_TRACE` | Enable function tracing | 0 | ✓ |
| `TROLLSTORE_HEAP_LOGGING` | Log heap allocations | 0 | ✓ |
| `TROLLSTORE_CRASH_REPORT` | Generate crash reports | 1 | ✓ |
| `TROLLSTORE_PERF_STATS` | Collect performance stats | 0 | ✓ |
| `TROLLSTORE_NET_DEBUG` | Network debugging | 0 | ✓ |
| `TROLLSTORE_IPC_LOG` | Log IPC communications | 0 | ✓ |
| `TROLLSTORE_UI_DEBUG` | Debug UI elements | 0 | ✓ |

### 5. Network Variables
Control network behavior and connectivity:

| Variable | Description | Default | Toggle |
|----------|-------------|---------|--------|
| `TROLLSTORE_PROXY_ENABLED` | Use custom proxy | 0 | ✓ |
| `TROLLSTORE_PROXY_HOST` | Proxy server address | Empty | - |
| `TROLLSTORE_PROXY_PORT` | Proxy server port | 0 | - |
| `TROLLSTORE_VPN_BYPASS` | Bypass VPN restrictions | 0 | ✓ |
| `TROLLSTORE_NET_RESTRICT` | Network restrictions | 0 | ✓ |
| `TROLLSTORE_DNS_SERVERS` | Custom DNS servers | System | - |
| `TROLLSTORE_NET_PRIORITY` | Network priority (0-3) | 1 | - |

### 6. Performance Variables
Optimize app performance and resource usage:

| Variable | Description | Default | Toggle |
|----------|-------------|---------|--------|
| `TROLLSTORE_CPU_LIMIT` | CPU usage limit (%) | 100 | - |
| `TROLLSTORE_MEM_LIMIT` | Memory limit (MB) | System | - |
| `TROLLSTORE_DISK_QUOTA` | Storage quota (MB) | Unlimited | - |
| `TROLLSTORE_POWER_MODE` | Power optimization | Auto | ✓ |
| `TROLLSTORE_THREAD_LIMIT` | Max thread count | Auto | - |
| `TROLLSTORE_IO_PRIORITY` | I/O priority (0-3) | 1 | - |
| `TROLLSTORE_GPU_FORCE` | Force GPU rendering | 0 | ✓ |

### 7. Integration Variables
System integration settings:

| Variable | Description | Default | Toggle |
|----------|-------------|---------|--------|
| `TROLLSTORE_URL_SCHEME` | Custom URL scheme | Default | - |
| `TROLLSTORE_SHARE_EXT` | Enable share extension | 0 | ✓ |
| `TROLLSTORE_SIRI_ALLOW` | Allow Siri integration | 0 | ✓ |
| `TROLLSTORE_NOTIFICATIONS` | Enable notifications | 1 | ✓ |
| `TROLLSTORE_BACKGROUND` | Background refresh | 0 | ✓ |
| `TROLLSTORE_LOCATION` | Location services | 0 | ✓ |
| `TROLLSTORE_CONTACTS` | Contacts access | 0 | ✓ |

### 8. Recovery Variables
For troubleshooting and recovery:

| Variable | Description | Default | Toggle |
|----------|-------------|---------|--------|
| `TROLLSTORE_RECOVERY_MODE` | Enable recovery mode | 0 | ✓ |
| `TROLLSTORE_BACKUP_FREQ` | Backup frequency (hours) | 24 | - |
| `TROLLSTORE_RESTORE_POINT` | Custom restore point | Latest | - |
| `TROLLSTORE_SAFE_MODE` | Run in safe mode | 0 | ✓ |
| `TROLLSTORE_AUTO_FIX` | Auto-fix common issues | 1 | ✓ |
| `TROLLSTORE_ROLLBACK` | Allow version rollback | 0 | ✓ |
| `TROLLSTORE_HEALTH_CHECK` | System health monitoring | 1 | ✓ |

### Variable Inheritance

Variables can inherit from multiple categories:

```plaintext
Base Variable
├── Public Interface
│   └── User Configurable
├── Private Implementation
│   └── System Critical
├── Security Level
│   ├── Basic
│   └── Enhanced
└── Function Type
    ├── Feature Control
    └── System Integration
```

### Dynamic Variables

Some variables can change behavior based on context:

1. **Context-Aware Variables**:
```
TROLLSTORE_POWER_MODE=auto    # Adjusts based on battery
TROLLSTORE_SECURITY=adaptive  # Changes with threat level
TROLLSTORE_PERFORMANCE=dynamic # Scales with system load
```

2. **Composite Variables**:
```
TROLLSTORE_PROTECTION={
  security_level: high,
  sandbox: enabled,
  encryption: required
}
```

### Variable States and Transitions

Variables can have multiple states:

```plaintext
State Diagram:
INACTIVE -> PENDING -> ACTIVE -> UPDATING
     ^                             |
     |_____________________________|
```

### Interaction Rules

1. **Dependency Chain**:
```
TROLLSTORE_JIT_ALLOW=1
  └── Requires: TROLLSTORE_SECURITY_LEVEL≤1
      └── Requires: TROLLSTORE_DEV_MODE=1
```

2. **Mutual Exclusion**:
```
TROLLSTORE_SAFE_MODE=1
  ⊕ TROLLSTORE_DEV_MODE=1    # Cannot both be active
```

3. **Complementary Variables**:
```
TROLLSTORE_DEBUG=1
  + TROLLSTORE_LOG_LEVEL=4   # Better together
```

## Credits & Version History
- Original TrollStore by @opa334
- Enhanced functionality by Alot1z
- Version 1.0.3: Advanced system integration

## TrollStore Enhanced Environment Variables

This document provides a comprehensive guide to all environment variables available in TrollStore Enhanced. Variables are organized by category and include detailed descriptions of their purpose, behavior, and usage.

## Categories Overview

Environment variables are grouped into the following categories:

1. Public Variables - User-configurable settings safe for modification
2. Private/System Variables - Core functionality settings requiring caution
3. Security Variables - Control app security and permissions
4. Development Variables - Tools for debugging and development
5. Network Variables - Control network behavior
6. Performance Variables - Optimize app performance
7. Integration Variables - Settings for system integration
8. Recovery Variables - Tools for troubleshooting and recovery

## Variable Details

### Public Variables

These variables are safe for users to modify and control basic app behavior:

- `TROLLSTORE_PERSIST`
  - Description: Keep app installed after reboot
  - Default: "0"
  - Type: Toggle
  - Example: Set to "1" to persist after reboot

### Security Variables

Control app security and permission levels:

- `TROLLSTORE_SECURITY_LEVEL`
  - Description: Security enforcement level
  - Default: "2"
  - Values: 0 (None) to 3 (Maximum)
  - Warning: Lower values reduce security

### Development Variables

Tools for developers and debugging:

- `TROLLSTORE_DEV_MODE`
  - Description: Enable developer features
  - Default: "0"
  - Type: Toggle
  - Note: Enables logging and debug tools

### Network Variables

Control network behavior and connectivity:

- `TROLLSTORE_PROXY_ENABLED`
  - Description: Use custom proxy
  - Default: "0"
  - Type: Toggle
  - Related: TROLLSTORE_PROXY_URL

### Performance Variables

Optimize app performance and resource usage:

- `TROLLSTORE_CPU_LIMIT`
  - Description: CPU usage limit
  - Default: "100"
  - Range: 0-100
  - Unit: Percentage

### Integration Variables

Control system integration features:

- `TROLLSTORE_URL_SCHEME`
  - Description: Custom URL scheme
  - Default: "trollstore"
  - Format: [a-z0-9]+

### Recovery Variables

Tools for troubleshooting and recovery:

- `TROLLSTORE_RECOVERY_MODE`
  - Description: Enable recovery mode
  - Default: "0"
  - Type: Toggle
  - Warning: May affect stability

## Variable Inheritance

Variables can inherit properties and behaviors:

1. Category Inheritance
   - Variables inherit default behaviors from their category
   - Category-specific validation rules apply

2. Value Inheritance
   - Some variables inherit values from system settings
   - Changes to parent values affect child variables

## Dynamic Variables

Variables that can change based on context:

1. System State
   - Battery level triggers
   - Network connectivity changes
   - Storage space thresholds

2. User Activity
   - Usage patterns
   - Time-based changes
   - Location-based adjustments

## Variable States

Variables can exist in multiple states:

1. `TSVariableStateInactive`
   - Variable is defined but not in use
   - Default values apply

2. `TSVariableStatePending`
   - Change requested but not applied
   - Waiting for conditions or approval

3. `TSVariableStateActive`
   - Variable is in use and affecting system
   - Current value is being applied

4. `TSVariableStateUpdating`
   - Value is being changed
   - Temporary state during transitions

## Interaction Rules

Guidelines for variable interactions:

1. Dependencies
   - Some variables require others to be active
   - Check dependency chain before changes

2. Conflicts
   - Some variables cannot be active together
   - System prevents conflicting states

3. Validation
   - Type-specific validation rules
   - Range and format checking
   - Security validation for sensitive variables

## Security Considerations

Important security guidelines:

1. Private Variables
   - Modification requires elevated privileges
   - Changes are logged and monitored

2. Security Variables
   - Cannot be modified while app is running
   - Require app restart to take effect

3. Recovery Variables
   - May bypass normal security checks
   - Use with caution

## Best Practices

Recommendations for variable management:

1. Documentation
   - Document all custom values
   - Keep track of changes

2. Testing
   - Test changes in safe environment
   - Verify behavior before production

3. Monitoring
   - Monitor variable states
   - Track performance impact

4. Recovery
   - Keep backup of working configuration
   - Know how to reset to defaults

## Examples

Common usage examples:

```bash
# Enable developer mode
TROLLSTORE_DEV_MODE=1

# Set maximum security
TROLLSTORE_SECURITY_LEVEL=3

# Custom URL scheme
TROLLSTORE_URL_SCHEME=myapp
```

## Support

For help with environment variables:

1. Check documentation first
2. Use recovery mode if needed
3. Contact support for assistance

Remember to always back up your configuration before making changes to environment variables.
