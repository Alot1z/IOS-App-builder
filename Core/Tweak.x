#import "TSEnvironmentManager.h"

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    
    // Initialize environment manager
    TSEnvironmentManager *manager = [TSEnvironmentManager sharedInstance];
    [manager setupEnvironmentVariables];
    [manager applyEntitlements];
}

%end
