#import "TSRootHelper.h"

@implementation TSRootHelper

+ (NSString *)binsPath {
    return [[NSBundle mainBundle] pathForResource:@"bins" ofType:nil];
}

+ (NSString *)toolPath:(NSString *)toolName {
    return [[self binsPath] stringByAppendingPathComponent:toolName];
}

+ (BOOL)installRootHelper:(NSString *)helperPath {
    // Sign the helper with proper entitlements
    NSString *entitlementsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"root_helper.plist"];
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [self toolPath:@"ldid"];
    task.arguments = @[@"-S", entitlementsPath, helperPath];
    
    [task launch];
    [task waitUntilExit];
    
    if (task.terminationStatus != 0) {
        return NO;
    }
    
    // Enable root capabilities
    task = [[NSTask alloc] init];
    task.launchPath = [self toolPath:@"choma"];
    task.arguments = @[@"--enable-root", helperPath];
    
    [task launch];
    [task waitUntilExit];
    
    return task.terminationStatus == 0;
}

+ (BOOL)removeRootHelper {
    NSString *helperPath = @"/var/root/trollstore_helper";
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error;
    [fm removeItemAtPath:helperPath error:&error];
    
    return error == nil;
}

+ (BOOL)isRootHelperInstalled {
    NSString *helperPath = @"/var/root/trollstore_helper";
    NSFileManager *fm = [NSFileManager defaultManager];
    
    return [fm fileExistsAtPath:helperPath];
}

+ (BOOL)executeWithRoot:(NSString *)command {
    if (![self isRootHelperInstalled]) {
        return NO;
    }
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/var/root/trollstore_helper";
    task.arguments = @[@"execute", command];
    
    [task launch];
    [task waitUntilExit];
    
    return task.terminationStatus == 0;
}

+ (BOOL)installApp:(NSString *)appPath withRoot:(BOOL)useRoot {
    if (!useRoot) {
        // Use normal installation process
        return [self installAppNormally:appPath];
    }
    
    if (![self isRootHelperInstalled]) {
        return NO;
    }
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/var/root/trollstore_helper";
    task.arguments = @[@"install", appPath];
    
    [task launch];
    [task waitUntilExit];
    
    return task.terminationStatus == 0;
}

+ (BOOL)uninstallApp:(NSString *)bundleID withRoot:(BOOL)useRoot {
    if (!useRoot) {
        // Use normal uninstallation process
        return [self uninstallAppNormally:bundleID];
    }
    
    if (![self isRootHelperInstalled]) {
        return NO;
    }
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/var/root/trollstore_helper";
    task.arguments = @[@"uninstall", bundleID];
    
    [task launch];
    [task waitUntilExit];
    
    return task.terminationStatus == 0;
}

#pragma mark - Private Methods

+ (BOOL)installAppNormally:(NSString *)appPath {
    // Normal installation logic using TrollStore's APIs
    // This would integrate with TrollStore's existing installation mechanism
    return NO; // TODO: Implement using TrollStore's API
}

+ (BOOL)uninstallAppNormally:(NSString *)bundleID {
    // Normal uninstallation logic using TrollStore's APIs
    // This would integrate with TrollStore's existing uninstallation mechanism
    return NO; // TODO: Implement using TrollStore's API
}

@end
