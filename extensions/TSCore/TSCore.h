#import <Foundation/Foundation.h>

@interface TSCore : NSObject

// Enhanced installation methods
+ (BOOL)installIPAWithPath:(NSString *)ipaPath;
+ (BOOL)installAppWithPath:(NSString *)appPath;
+ (BOOL)uninstallAppWithBundleID:(NSString *)bundleID;

// Enhanced signing methods
+ (BOOL)signBinaryAtPath:(NSString *)binaryPath withEntitlements:(NSDictionary *)entitlements;
+ (BOOL)verifySignatureOfBinaryAtPath:(NSString *)binaryPath;

// Enhanced app management
+ (NSArray *)listInstalledApps;
+ (NSDictionary *)getAppInfoForBundleID:(NSString *)bundleID;

// Enhanced root capabilities
+ (BOOL)hasRootAccess;
+ (BOOL)executeCommandWithRoot:(NSString *)command;

@end
