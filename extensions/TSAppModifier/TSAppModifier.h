#import <Foundation/Foundation.h>

@interface TSAppModifier : NSObject

// Enhanced app modification methods
+ (BOOL)extractApp:(NSString *)appPath toPath:(NSString *)extractPath;
+ (BOOL)repackApp:(NSString *)appPath toPath:(NSString *)outputPath;
+ (BOOL)patchBinary:(NSString *)binaryPath withEntitlements:(NSString *)entitlements;

// New TrollStore2 features
+ (BOOL)enableJIT:(NSString *)binaryPath;
+ (BOOL)patchSandbox:(NSString *)binaryPath;
+ (BOOL)enableDebug:(NSString *)binaryPath;
+ (BOOL)enableRoot:(NSString *)binaryPath;

@end
