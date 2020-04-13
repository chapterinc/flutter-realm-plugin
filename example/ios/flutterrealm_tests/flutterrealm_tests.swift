//
//  flutterrealm_light_tests.swift
//  flutterrealm_light_tests
//
//  Created by Grigori on 2/25/20.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import XCTest
import Flutter
import flutterrealm_light;

class flutterrealm_light_tests: XCTestCase {

    /// Add enviroment variables inside Xcode project for start test
    var realmJwt = ""
    var realmServerPath = "";
    var realmDatabasePath = "";

    override func setUp() {
        realmJwt = String(cString: getenv("realmJwt"))
        realmServerPath = String(cString: getenv("realmServerPath"))
        realmDatabasePath = String(cString: getenv("realmDatabasePath"))
    }

    override func tearDown() {

    }

    func testFetchAll() {
        let expectation = self.expectation(description: #function)

        let call = FlutterMethodCall.init(methodName: "allUsers", arguments: [])
        SwiftFlutterrealm_lightPlugin().handle(call) { (result) in
            if let users = result as? [[String: [String: Any]]]{
                print("users count is: \(users.count)")
            }else{
               assert(true, "users result have not correct type")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testLogin() {
        let expectation = self.expectation(description: #function)

        let call = FlutterMethodCall.init(methodName: "login", arguments: ["jwt": realmJwt, "server": realmServerPath])
        SwiftFlutterrealm_lightPlugin().handle(call) { (result) in
            if let dictionary = result as? [String: Any], let error = dictionary["error"]{
                assert(false, "error = \(error)")
            }

            if let user = result as? [String: Any] {
                print("logged in by user: \(user["identity"] ?? "")")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 120)
    }

    func testCreatePhoto() {
        func getPhotoDictionary() -> [String: Any]{
            let value: [String: Any] = ["id": "1234ff", "burstIdentifier": "ssss", "createdDate": Int64(Date().timeIntervalSince1970 * 1000), "creationDate": Int64(Date().timeIntervalSince1970 * 1000), "sortedDate": Int64(Date().timeIntervalSince1970 * 1000), "mediaType": "sss", "modificationDate": Int64(Date().timeIntervalSince1970 * 1000), "subType": 1, "type": 0, "isUploaded": true, "isTrashed": true, "isSorted": true, "userId": "2", "sortIndex": 1.0, "duration": 0.0, "pixelWidth": 2, "pixelHeight": 100, "startTime": 0.0, "endTime": 0.0, "timeScale": 2, "year": 2000, "month": 201, "photoDetail" : ["centerx" : 10], "albums":[["id": "ttttt"]]]

            return value
        }

        let expectation = self.expectation(description: #function)

        userIdentity(success: { (identity) in
            // Begin write
            let type = "Photo"

            // Add required property in dictionary
            let value: [String: Any] = getPhotoDictionary()
            let policy = 2
            let create = FlutterMethodCall.init(methodName: "create", arguments: ["type": type, "value": value, "policy": policy, "identity": identity, "databaseUrl": self.realmDatabasePath])
            SwiftFlutterrealm_lightPlugin().handle(create) { (result) in
                if let dictionary = result as? [String: Any], let error = dictionary["error"]{
                    assert(false, "error = \(error)")
                }

                if let photo = result as? [String: Any]{
                    assert(NSDictionary(dictionary: photo).isEqual(to: value), "users result have not correct type")
                }else{
                    assert(false, "users result have not correct type")
                }

                expectation.fulfill()
            }
        }, error: {
               assert(false, "users result have not correct type")
            })
        
        waitForExpectations(timeout: 120)
    }
    
    func testDeletePhoto() {
        let expectation = self.expectation(description: "delete photo")

        testQuery(success: {dictionary in
            guard let id = dictionary?.first?["id"] as? String else{
                return
            }
            self.deleteObject(primaryKey: id) { () in
                expectation.fulfill()
            }
        })

        waitForExpectations(timeout: 10)
    }

    func testQueries() {
        let expectation = self.expectation(description: #function)
        waitForExpectations(timeout: 10)

        testQuery(success: {_ in })
        sleep(2)

        testQuery(query: "type == 1", success: {_ in })
        sleep(2)

        testQuery(query: "type == 2", limit: 1, success: {_ in })
        sleep(2)

        expectation.fulfill()
    }
    
    func deleteObject(primaryKey: String, success: @escaping () -> ()) {
        userIdentity(success: { (identity) in
            let type = "Photo"

            let deleteQuery = FlutterMethodCall.init(methodName: "delete", arguments: ["primaryKey": primaryKey, "type": type, "identity": identity, "databaseUrl": self.realmDatabasePath])
                SwiftFlutterrealm_lightPlugin().handle(deleteQuery) { (result) in
                    success()
                }
            
        }, error: {
            assert(false, "users result have not correct type")
        })
    }
    
    func testQuery(query: String? = nil, limit: Int? = nil, success: @escaping ([[String: Any]]?) -> ()) {
        userIdentity(success: { (identity) in
            let value = [String: Any]()
            let policy = 2
            let type = "Photo"

            let create = FlutterMethodCall.init(methodName: "objects", arguments: ["type": type, "value": value, "limit": limit ?? 0, "policy": policy, "identity": identity, "databaseUrl": self.realmDatabasePath])
            SwiftFlutterrealm_lightPlugin().handle(create) { (result) in
                if let dictionary = result as? [String: Any], let error = dictionary["error"]{
                    assert(false, "error = \(error)")
                }

//                assert(result is [String: Any], "users result have not correct type")

                if let dictionary = result as? [String: Any]{
                    success(dictionary["results"] as? [[String: Any]])
                }
            }
        }, error: {
               assert(false, "users result have not correct type")
        })
    }

    func userIdentity(success: @escaping (String) -> (), error: @escaping () -> ()){
        let call = FlutterMethodCall.init(methodName: "allUsers", arguments: [])
        SwiftFlutterrealm_lightPlugin().handle(call) { (result) in
            if let dictionary = result as? [String: Any], let error = dictionary["error"]{
                assert(false, "error = \(error)")
            }

            let _users = result as? [String: Any]
            let _identity = _users?["results"] as? [[String: [String: Any]]]
            if let identity = _identity?.first?.first?.key{
                success(identity)
            }else{
                error()
            }
        }
    }

    func testPerforsmanceExample() {
        measure {
        }
    }

    func testPerformanceExample() {
        measure {
        }
    }

}

