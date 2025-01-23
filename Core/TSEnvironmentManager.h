#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TSEnvironmentCategory) {
    TSEnvironmentCategoryPublic,
    TSEnvironmentCategoryPrivate,
    TSEnvironmentCategorySecurity,
    TSEnvironmentCategoryDevelopment,
    TSEnvironmentCategoryNetwork,
    TSEnvironmentCategoryPerformance,
    TSEnvironmentCategoryIntegration,
    TSEnvironmentCategoryRecovery
};

typedef NS_ENUM(NSInteger, TSVariableState) {
    TSVariableStateInactive,
    TSVariableStatePending,
    TSVariableStateActive,
    TSVariableStateUpdating
};

@interface TSEnvironmentVariable : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *defaultValue;
@property (nonatomic, assign) BOOL isToggle;
@property (nonatomic, assign) TSEnvironmentCategory category;
@property (nonatomic, strong) NSString *currentValue;
@property (nonatomic, strong) NSArray<NSString *> *examples;
@property (nonatomic, strong) NSArray<NSString *> *warnings;
@property (nonatomic, strong) NSArray<NSString *> *affectedComponents;
@property (nonatomic, assign) TSVariableState state;
@property (nonatomic, strong) NSArray<NSString *> *dependencies;
@property (nonatomic, strong) NSArray<NSString *> *conflicts;
@property (nonatomic, assign) BOOL isDynamic;
@property (nonatomic, strong) NSDictionary *dynamicBehavior;

- (instancetype)initWithName:(NSString *)name
                description:(NSString *)description
               defaultValue:(NSString *)defaultValue
                 isToggle:(BOOL)isToggle
                category:(TSEnvironmentCategory)category;

- (BOOL)validateValue:(NSString *)value;
- (BOOL)canTransitionToState:(TSVariableState)newState;
- (NSArray<NSString *> *)requiredRestarts;

@end

@interface TSEnvironmentManager : NSObject

+ (instancetype)sharedManager;

// Category Management
- (NSArray<TSEnvironmentVariable *> *)variablesInCategory:(TSEnvironmentCategory)category;
- (TSEnvironmentCategory)categoryForVariable:(NSString *)name;

// Variable Management
- (NSArray<TSEnvironmentVariable *> *)allVariables;
- (TSEnvironmentVariable *)variableForName:(NSString *)name;
- (BOOL)addVariable:(TSEnvironmentVariable *)variable;
- (BOOL)removeVariable:(NSString *)name;

// Value Management
- (void)setValue:(NSString *)value forVariable:(NSString *)name;
- (NSString *)valueForVariable:(NSString *)name;
- (void)resetAllVariables;
- (void)resetCategory:(TSEnvironmentCategory)category;

// State Management
- (TSVariableState)stateForVariable:(NSString *)name;
- (BOOL)activateVariable:(NSString *)name;
- (BOOL)deactivateVariable:(NSString *)name;

// Configuration Management
- (void)saveConfiguration;
- (void)loadConfiguration;
- (void)exportConfiguration:(NSString *)path;
- (void)importConfiguration:(NSString *)path;
- (void)migrateConfiguration;

// Presets
- (void)applyPreset:(NSString *)presetName;
- (NSDictionary *)availablePresets;
- (void)saveCurrentAsPreset:(NSString *)name;

// Dependencies
- (BOOL)checkDependencies:(NSString *)variableName;
- (NSArray<NSString *> *)conflictingVariables:(NSString *)variableName;
- (NSArray<NSString *> *)requiredVariables:(NSString *)variableName;

// Dynamic Variables
- (void)updateDynamicVariables;
- (NSDictionary *)dynamicStateForVariable:(NSString *)name;

// Status & Validation
- (NSDictionary *)variableStatus;
- (BOOL)needsReinstall;
- (NSArray<NSString *> *)validationErrors;
- (BOOL)validateConfiguration;

// Security
- (BOOL)isSecureVariable:(NSString *)name;
- (void)lockSecureVariables;
- (void)unlockSecureVariables;

// Monitoring
- (void)startMonitoring;
- (void)stopMonitoring;
- (NSDictionary *)currentMetrics;

@end
