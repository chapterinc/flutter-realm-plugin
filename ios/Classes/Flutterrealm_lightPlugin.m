#import "Flutterrealm_lightPlugin.h"
#if __has_include(<flutterrealm_light/flutterrealm_light-Swift.h>)
#import <flutterrealm_light/flutterrealm_light-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutterrealm_light-Swift.h"
#endif

@implementation Flutterrealm_lightPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterrealm_lightPlugin registerWithRegistrar:registrar];
}
@end
