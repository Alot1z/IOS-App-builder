#import "TSAppModifier.h"

@implementation TSAppModifier

+ (NSString *)binsPath {
    return [[NSBundle mainBundle] pathForResource:@"bins" ofType:nil];
}

+ (NSString *)toolPath:(NSString *)toolName {
    return [[self binsPath] stringByAppendingPathComponent:toolName];
}

+ (BOOL)extractApp:(NSString *)appPath toPath:(NSString *)extractPath {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [self toolPath:@"unzip"];
    task.arguments = @[@"-q", appPath, @"-d", extractPath];
    
    [task launch];
    [task waitUntilExit];
    
    return task.terminationStatus == 0;
}

+ (BOOL)repackApp:(NSString *)appPath toPath:(NSString *)outputPath {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [self toolPath:@"unzip"];
    task.arguments = @[@"-r", outputPath, @"Payload/"];
    task.currentDirectoryPath = appPath;
    
    [task launch];
    [task waitUntilExit];
    
    return task.terminationStatus == 0;
}

+ (BOOL)patchBinary:(NSString *)binaryPath withEntitlements:(NSString *)entitlements {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [self toolPath:@"ldid"];
    task.arguments = @[@"-S", entitlements, binaryPath];
    
    [task launch];
    [task waitUntilExit];
    
    return task.terminationStatus == 0;
}

+ (BOOL)enableJIT:(NSString *)binaryPath {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [self toolPath:@"choma"];
    task.arguments = @[@"--enable-jit", binaryPath];
    
    [task launch];
    [task waitUntilExit];
    
    return task.terminationStatus == 0;
}

+ (BOOL)patchSandbox:(NSString *)binaryPath {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [self toolPath:@"choma"];
    task.arguments = @[@"--patch-sandbox", binaryPath];
    
    [task launch];
    [task waitUntilExit];
    
    return task.terminationStatus == 0;
}

+ (BOOL)enableDebug:(NSString *)binaryPath {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [self toolPath:@"choma"];
    task.arguments = @[@"--enable-debug", binaryPath];
    
    [task launch];
    [task waitUntilExit];
    
    return task.terminationStatus == 0;
}

+ (BOOL)enableRoot:(NSString *)binaryPath {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [self toolPath:@"choma"];
    task.arguments = @[@"--enable-root", binaryPath];
    
    [task launch];
    [task waitUntilExit];
    
    return task.terminationStatus == 0;
}

@end
