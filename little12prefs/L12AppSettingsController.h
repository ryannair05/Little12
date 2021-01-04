#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface L12AppSettingsController : PSListController
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *bundleIdentifier;
@end
