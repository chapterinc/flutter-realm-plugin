import Flutter
import UIKit
import RealmSwift
import Realm.Dynamic
import Realm.Private

enum Action: String {
    case objects
    case count
    case last
    case create
    case delete
    case login
    case logout
    case logoutAll
    case allUsers
    case subscribe
    case unSubscribe
    case asyncOpen
    case deleteAll
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
            rootQueries[appId] = RealmQuery(realmApp: app, channel: channel, searializeConnection: app.searializeConnection())
        }
            
        let realmQuery = rootQueries[appId]
        assert(realmQuery != nil, "Query cannot be null in this case")

        if let query = anyQuery(){
            restartSessionWhenNeeded(action: action, realmQuery: query)
        }
        
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
    
    
    
    private func restartSessionWhenNeeded(action: Action, realmQuery: RealmQuery){
        switch action {
        case .allUsers:
            break
        case .objects:
            break
        case .count:
            break
        case .last:
            break
        case .create:
            break
        case .delete:
            break
        case .subscribe:
            break
        case .unSubscribe:
            break
        case .asyncOpen:
            break
        case .login:
            realmQuery.searializeConnection = nil
        case .logout:
            realmQuery.searializeConnection = nil
        case .logoutAll:
            realmQuery.searializeConnection = nil
        case .deleteAll:
            realmQuery.searializeConnection = nil
        }
        guard realmQuery.realmApp.loggedInUsersCount() > 1 else {
            return
        }
        realmQuery.searializeConnection?.restartSessions()
    }
    
    private func anyQuery() -> RealmQuery?{
        return rootQueries.first?.value
    }
}

private extension App{
    func loggedInUsersCount() -> Int{
        return allUsers.reduce(0) { (result, arg1) -> Int in
            let (_, value) = arg1
            
            if value.isLoggedIn{
                return result + 1
            }else{
                return result
            }
        }
    }
    
    
    func searializeConnection() -> SerializeConnection?{
        guard loggedInUsersCount() > 1 else {
            return nil
        }

        return SerializeConnection(app: self)
    }
}

