import Flutter
import UIKit
import RealmSwift
import Realm.Dynamic
import Realm.Private

enum Action: String {
    case objects
    case internalObjects
    case count
    case last
    case create
    case createList
    case delete
    case login
    case logout
    case logoutAll
    case allUsers
    case watch
    case subscribe
    case unSubscribe
    case asyncOpen
    case deleteAll
    case indexObject
}

public class SwiftFlutterrealm_lightPlugin: NSObject, FlutterPlugin {
    static let noArgumentsWasPassesError = "no arguments was passed"
    static let oneOffArgumentsNotPassesError = "one of arguments not passed correctly"
    static let notFoundForGivenIdentityError = "user not found for given identity"
    static let objectNotFoundForGivenIdentity = "object not found for given identity"

    let global = DispatchQueue.global()

    var channel: FlutterMethodChannel?

    var rootQueries = [String: RealmQuery]()
    
    public init(channel: FlutterMethodChannel? = nil) {
        self.channel = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutterrealm_light", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterrealm_lightPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)

    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let action = Action(rawValue: call.method) else{
            result(["error": "Problem on parse action"])
            return
        }

        guard let dictionary = call.arguments as? NSDictionary else{
            result(["error": SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError])
            return
        }

        guard let appId = dictionary["appId"] as? String else{
            result(["error": "App id was not set"])
            return
        }

        if(rootQueries[appId] == nil){
            let app = RLMApp(id: appId)
            rootQueries[appId] = RealmQuery(realmApp: app, channel: channel)
        }
            
        let realmQuery = rootQueries[appId]
        assert(realmQuery != nil, "Query cannot be null in this case")

        func continueAction(){
            do {
                try realmQuery?.continueAction(action: action, call: call, result: result)
            }catch {
                result(["error": "\(error)"])
            }
        }
        if action == .subscribe || action == .unSubscribe{
            continueAction()
        }else{
            global.async {
                continueAction()
            }
        }
    }
}
