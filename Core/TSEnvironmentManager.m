#import "TSEnvironmentManager.h"

@implementation TSEnvironmentVariable

- (instancetype)initWithName:(NSString *)name
                description:(NSString *)description
               defaultValue:(NSString *)defaultValue
                 isToggle:(BOOL)isToggle
                isPrivate:(BOOL)isPrivate {
    if (self = [super init]) {
        _name = name;
        _description = description;
        _defaultValue = defaultValue;
        _isToggle = isToggle;
        _isPrivate = isPrivate;
        _currentValue = defaultValue;
        _examples = @[];
        _warnings = @[];
        _affectedComponents = @[];
    }
    return self;
}

@end

@interface TSEnvironmentManager ()
@property (nonatomic, strong) NSMutableDictionary *variables;
@property (nonatomic, strong) NSMutableDictionary *presets;
@end

@implementation TSEnvironmentManager

+ (instancetype)sharedManager {
    static TSEnvironmentManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupVariables];
        [self setupPresets];
        [self loadConfiguration];
    }
    return self;
}

- (void)setupVariables {
    self.variables = [NSMutableDictionary dictionary];
    
    // Public Variables
    [self addVariable:[[TSEnvironmentVariable alloc] initWithName:@"TROLLSTORE_PERSIST"
                                                    description:@"Keep app installed after reboot"
                                                   defaultValue:@"0"
                                                     isToggle:YES
                                                    isPrivate:NO]];
    
    [self addVariable:[[TSEnvironmentVariable alloc] initWithName:@"TROLLSTORE_ENTITLEMENTS"
                                                    description:@"Enable all entitlements"
                                                   defaultValue:@"0"
                                                     isToggle:YES
                                                    isPrivate:NO]];
    
    // Add more public variables...
    
    // Private Variables
    [self addVariable:[[TSEnvironmentVariable alloc] initWithName:@"DYLD_INSERT_LIBRARIES"
                                                    description:@"Load custom dylibs"
                                                   defaultValue:@""
                                                     isToggle:YES
                                                    isPrivate:YES]];
    
    // Add more private variables...
}

- (void)addVariable:(TSEnvironmentVariable *)variable {
    self.variables[variable.name] = variable;
}

- (void)setupPresets {
    self.presets = [@{
        @"Maximum Freedom": @{
            @"TROLLSTORE_PERSIST": @"1",
            @"TROLLSTORE_ENTITLEMENTS": @"1",
            @"TROLLSTORE_NO_SANDBOX": @"1"
        },
        @"Maximum Security": @{
            @"TROLLSTORE_SIGNATURES": @"1",
            @"TROLLSTORE_NO_SANDBOX": @"0",
            @"TROLLSTORE_ENTITLEMENTS": @"0"
        },
        @"Developer Mode": @{
            @"TROLLSTORE_DEBUG": @"1",
            @"TROLLSTORE_LOG_LEVEL": @"4",
            @"TROLLSTORE_PERSIST": @"1"
        }
    } mutableCopy];
}

#pragma mark - Variable Management

- (NSArray<TSEnvironmentVariable *> *)publicVariables {
    return [self.variables.allValues filteredArrayUsingPredicate:
            [NSPredicate predicateWithFormat:@"isPrivate == NO"]];
}

- (NSArray<TSEnvironmentVariable *> *)privateVariables {
    return [self.variables.allValues filteredArrayUsingPredicate:
            [NSPredicate predicateWithFormat:@"isPrivate == YES"]];
}

- (TSEnvironmentVariable *)variableForName:(NSString *)name {
    return self.variables[name];
}

#pragma mark - Value Management

- (void)setValue:(NSString *)value forVariable:(NSString *)name {
    TSEnvironmentVariable *variable = [self variableForName:name];
    if (variable) {
        variable.currentValue = value;
        [self saveConfiguration];
    }
}

- (NSString *)valueForVariable:(NSString *)name {
    TSEnvironmentVariable *variable = [self variableForName:name];
    return variable ? variable.currentValue : nil;
}

- (void)resetAllVariables {
    for (TSEnvironmentVariable *variable in self.variables.allValues) {
        variable.currentValue = variable.defaultValue;
    }
    [self saveConfiguration];
}

#pragma mark - Configuration Management

- (void)saveConfiguration {
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    for (TSEnvironmentVariable *variable in self.variables.allValues) {
        if (![variable.currentValue isEqualToString:variable.defaultValue]) {
            config[variable.name] = variable.currentValue;
        }
    }
    
    NSString *configPath = [self configurationPath];
    [config writeToFile:configPath atomically:YES];
}

- (void)loadConfiguration {
    NSString *configPath = [self configurationPath];
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:configPath];
    
    if (config) {
        for (NSString *name in config) {
            TSEnvironmentVariable *variable = [self variableForName:name];
            if (variable) {
                variable.currentValue = config[name];
            }
        }
    }
}

- (NSString *)configurationPath {
    NSString *appSupport = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    return [appSupport stringByAppendingPathComponent:@"TSEnvironment.plist"];
}

- (void)exportConfiguration:(NSString *)path {
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    for (TSEnvironmentVariable *variable in self.variables.allValues) {
        config[variable.name] = @{
            @"value": variable.currentValue,
            @"isPrivate": @(variable.isPrivate),
            @"isToggle": @(variable.isToggle)
        };
    }
    
    [config writeToFile:path atomically:YES];
}

- (void)importConfiguration:(NSString *)path {
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:path];
    if (!config) return;
    
    for (NSString *name in config) {
        NSDictionary *varConfig = config[name];
        TSEnvironmentVariable *variable = [self variableForName:name];
        if (variable) {
            variable.currentValue = varConfig[@"value"];
        }
    }
    
    [self saveConfiguration];
}

#pragma mark - Presets

- (void)applyPreset:(NSString *)presetName {
    NSDictionary *preset = self.presets[presetName];
    if (!preset) return;
    
    for (NSString *name in preset) {
        [self setValue:preset[name] forVariable:name];
    }
}

- (NSDictionary *)availablePresets {
    return [self.presets copy];
}

#pragma mark - Status

- (NSDictionary *)variableStatus {
    NSMutableDictionary *status = [NSMutableDictionary dictionary];
    
    for (TSEnvironmentVariable *variable in self.variables.allValues) {
        if (![variable.currentValue isEqualToString:variable.defaultValue]) {
            status[variable.name] = @{
                @"changed": @YES,
                @"needsRestart": @([self variableNeedsRestart:variable.name])
            };
        }
    }
    
    return status;
}

- (BOOL)variableNeedsRestart:(NSString *)name {
    // Add logic for which variables need restart
    NSArray *restartNeeded = @[
        @"TROLLSTORE_PERSIST",
        @"TROLLSTORE_ENTITLEMENTS",
        @"DYLD_INSERT_LIBRARIES"
    ];
    
    return [restartNeeded containsObject:name];
}

- (BOOL)needsReinstall {
    NSDictionary *status = [self variableStatus];
    
    for (NSString *name in status) {
        NSDictionary *varStatus = status[name];
        if ([varStatus[@"needsRestart"] boolValue]) {
            return YES;
        }
    }
    
    return NO;
}

@end
