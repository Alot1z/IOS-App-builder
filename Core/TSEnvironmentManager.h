#import <Foundation/Foundation.h>

@interface TSEnvironmentVariable : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *defaultValue;
@property (nonatomic, assign) BOOL isToggle;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, strong) NSString *currentValue;
@property (nonatomic, strong) NSArray<NSString *> *examples;
@property (nonatomic, strong) NSArray<NSString *> *warnings;
@property (nonatomic, strong) NSArray<NSString *> *affectedComponents;

- (instancetype)initWithName:(NSString *)name
                description:(NSString *)description
               defaultValue:(NSString *)defaultValue
                 isToggle:(BOOL)isToggle
                isPrivate:(BOOL)isPrivate;

@end

@interface TSEnvironmentManager : NSObject

+ (instancetype)sharedManager;

// Variable Management
- (NSArray<TSEnvironmentVariable *> *)publicVariables;
- (NSArray<TSEnvironmentVariable *> *)privateVariables;
- (TSEnvironmentVariable *)variableForName:(NSString *)name;

// Value Management
- (void)setValue:(NSString *)value forVariable:(NSString *)name;
- (NSString *)valueForVariable:(NSString *)name;
- (void)resetAllVariables;

// Configuration Management
- (void)saveConfiguration;
- (void)loadConfiguration;
- (void)exportConfiguration:(NSString *)path;
- (void)importConfiguration:(NSString *)path;

// Presets
- (void)applyPreset:(NSString *)presetName;
- (NSDictionary *)availablePresets;

// Status
- (NSDictionary *)variableStatus;
- (BOOL)needsReinstall;

@end
