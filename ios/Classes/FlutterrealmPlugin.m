#import "FlutterrealmPlugin.h"
#if __has_include(<flutterrealm/flutterrealm-Swift.h>)
#import <flutterrealm/flutterrealm-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutterrealm-Swift.h"
#endif

@implementation FlutterrealmPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterrealmPlugin registerWithRegistrar:registrar];
}
@end
