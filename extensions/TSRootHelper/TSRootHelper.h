#import <Foundation/Foundation.h>

@interface TSRootHelper : NSObject

// Enhanced root capabilities
+ (BOOL)installRootHelper:(NSString *)helperPath;
+ (BOOL)removeRootHelper;
+ (BOOL)isRootHelperInstalled;

// Root operations
+ (BOOL)executeWithRoot:(NSString *)command;
+ (BOOL)installApp:(NSString *)appPath withRoot:(BOOL)useRoot;
+ (BOOL)uninstallApp:(NSString *)bundleID withRoot:(BOOL)useRoot;

@end
