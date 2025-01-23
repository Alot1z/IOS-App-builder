#import <Foundation/Foundation.h>

@interface TSInstaller : NSObject

// Enhanced installation capabilities
+ (BOOL)installEnhancedIPA:(NSString *)ipaPath;
+ (BOOL)installEnhancedApp:(NSString *)appPath;
+ (BOOL)patchAndInstallApp:(NSString *)appPath withOptions:(NSDictionary *)options;

// App verification
+ (BOOL)verifyAppIntegrity:(NSString *)appPath;
+ (BOOL)validateAppEntitlements:(NSString *)appPath;

// Installation helpers
+ (BOOL)prepareAppForInstallation:(NSString *)appPath;
+ (void)cleanupAfterInstallation:(NSString *)appPath;

@end
