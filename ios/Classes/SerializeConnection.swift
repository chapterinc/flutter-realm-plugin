//
//  SerializeConnection.swift
//  flutterrealm_light
//
//  Created by Grigori on 4/29/21.
//

import Foundation
import RealmSwift
import Realm.Dynamic
import Realm.Private

class SerializeConnection{
    init(app: App){
        self.app = app
        
        repeatTenTimeReset()
    }

    private final var app: App
    private final var alreadySuspendedSession = NSMutableDictionary()
    private final var observers = NSMutableArray()
    
    /// Current session
    private var currentSession: RLMSyncSession?
    
    /// We us this since on start app realm crashing when we have multiply realms
    /// So this function restart resume session after some delay
    /// Since this happened only first time I run this method for every user one time
    func restartSessions(){
        for (index, user) in app.allUsers.enumerated() {
            for session in user.value.allSessions{
                if alreadySuspendedSession["\(user.key)"] != nil{
                    continue
                }
                
                session.suspend()
                observe(session: session)
                alreadySuspendedSession["\(user.key)"] = true
                print("suspend: \(user.key), time: \(index)")
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index)) {
                    self.resume(session: session)
                }
            }
        }
    }
    
    deinit {
        for observer in observers{
            if let o = observer as? NSKeyValueObservation{
                o.invalidate()
            }
        }
        
        observers.removeAllObjects()
    }

    
    /// Check if realm in connecting process
    private func isAnyConnecting() -> Bool{
        for user in app.allUsers {
            for session in user.value.allSessions{
                if session.connectionState == .connecting{
                    return true
                }
            }
        }
        return false
    }
    
    /// Resume session if no any connecting
    private func resume(session: RLMSyncSession){
        func runAfterDelay(){
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.resume(session: session)
            }
        }
        guard !isAnyConnecting() else{
            runAfterDelay()
            return
        }
        
        currentSession = session
        session.resume()
    }
    
    
    /// Observe session stop any connection not equal to currentSession
    private func observe(session: RLMSyncSession){
        let observer = session.observe(\.connectionState, options: [.initial]) {[weak self] (syncSession, change) in
            switch syncSession.connectionState {
            case .connecting:
                if syncSession != self?.currentSession{
                    print("suspend")
                    syncSession.suspend()
                }
            case .connected:
                if self?.currentSession == syncSession{
                    self?.currentSession = nil
                }
                break;
            case .disconnected:
                if self?.currentSession == syncSession{
                    self?.currentSession = nil
                }
                break;
            default:
                break
            }
        }
        observers.add(observer)
    }
}


extension SerializeConnection{
    /// Repeate ten time restart and observe new session
    func repeatTenTimeReset(){
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            count += 1
            
            self?.restartSessions()
            
            if count >= 10{
                timer.invalidate()
            }
        }
    }
}

