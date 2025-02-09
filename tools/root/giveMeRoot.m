#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/stat.h>
#import <dlfcn.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <sys/syscall.h>
#import <mach/mach.h>
#import <sys/utsname.h>

#define POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE 1
#define POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE_ORIG 2

extern int posix_spawnattr_set_persona_np(const posix_spawnattr_t* __restrict, uid_t, uint32_t);
extern int posix_spawnattr_set_persona_uid_np(const posix_spawnattr_t* __restrict, uid_t);
extern int posix_spawnattr_set_persona_gid_np(const posix_spawnattr_t* __restrict, uid_t);

@interface RootHelper : NSObject
+ (int)gainRoot;
+ (BOOL)isJailbroken;
+ (void)enableFileAccess;
+ (void)enableSystemAccess;
@end

@implementation RootHelper

+ (int)gainRoot {
    if (![self isJailbroken]) return 1;
    
    posix_spawnattr_t attr;
    posix_spawnattr_init(&attr);
    
    // Set root privileges
    posix_spawnattr_set_persona_np(&attr, 0, POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE);
    posix_spawnattr_set_persona_uid_np(&attr, 0);
    posix_spawnattr_set_persona_gid_np(&attr, 0);
    
    // Enable file system access
    [self enableFileAccess];
    [self enableSystemAccess];
    
    return 0;
}

+ (BOOL)isJailbroken {
    struct stat info;
    return (stat("/var/lib/dpkg/", &info) == 0) ? YES : NO;
}

+ (void)enableFileAccess {
    // Enable access to protected directories
    NSArray *paths = @[
        @"/var/mobile",
        @"/var/root",
        @"/var/db",
        @"/var/jb",
        @"/var/log",
        @"/private/var"
    ];
    
    for (NSString *path in paths) {
        char const *pathStr = [path UTF8String];
        chmod(pathStr, 0777);
    }
}

+ (void)enableSystemAccess {
    // Enable system level access
    setuid(0);
    setgid(0);
    
    // Grant additional permissions
    syscall(SYS_ptrace, 0, 0, 0, 0);
}

@end
