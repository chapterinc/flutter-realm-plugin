//
//  flutterrealm_tests.swift
//  flutterrealm_tests
//
//  Created by Grigori on 2/25/20.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import XCTest
import Flutter
import flutterrealm;

class flutterrealm_tests: XCTestCase {

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
        SwiftFlutterrealmPlugin().handle(call) { (result) in
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
        SwiftFlutterrealmPlugin().handle(call) { (result) in
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
            let value: [String: Any] = ["id": "1234ff", "burstIdentifier": "ssss", "createdDate": Int64(Date().timeIntervalSince1970 * 1000), "creationDate": Int64(Date().timeIntervalSince1970 * 1000), "sortedDate": Int64(Date().timeIntervalSince1970 * 1000), "mediaType": "sss", "modificationDate": Int64(Date().timeIntervalSince1970 * 1000), "subType": 1, "type": 0, "isUploaded": true, "isTrashed": true, "isSorted": true, "userId": "2", "sortIndex": 1.0, "duration": 0.0, "pixelWidth": 2, "pixelHeight": 100, "startTime": 0.0, "endTime": 0.0, "timeScale": 2, "year": 2000, "month": 201, "photoDetail" : ["centerx" : 10]]

            return value
        }

        let expectation = self.expectation(description: #function)

        let call = FlutterMethodCall.init(methodName: "allUsers", arguments: [])
        SwiftFlutterrealmPlugin().handle(call) { (result) in
            if let dictionary = result as? [String: Any], let error = dictionary["error"]{
                assert(false, "error = \(error)")
            }

            let _users = result as? [String: Any]
            let _identity = _users?["results"] as? [[String: [String: Any]]]
            if let identity = _identity?.first?.first?.key{
                            if let dictionary = result as? [String: Any], let error = dictionary["error"]{
                                assert(false, "error = \(error)")
                            }

                            // Begin write
                            let type = "Photo"

                            // Add required property in dictionary
                            let value: [String: Any] = getPhotoDictionary()
                            let policy = 2
                            let create = FlutterMethodCall.init(methodName: "create", arguments: ["type": type, "value": value, "policy": policy, "identity": identity, "databaseUrl": self.realmDatabasePath])
                                SwiftFlutterrealmPlugin().handle(create) { (result) in
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
            }else{
               assert(false, "users result have not correct type")
            }
        }
        waitForExpectations(timeout: 120)
    }
    
    /// Test load data on different predicates
    func testQueries() {
        let expectation = self.expectation(description: #function)
        waitForExpectations(timeout: 10)

        testQuery()
        sleep(2)
        
        testQuery(query: "type == 1")
        sleep(2)

        testQuery(query: "type == 2", limit: 1)
        sleep(2)
        
        expectation.fulfill()
    }
    
    func testQuery(query: String? = nil, limit: Int? = nil) {
        let call = FlutterMethodCall.init(methodName: "allUsers", arguments: [])
        SwiftFlutterrealmPlugin().handle(call) { (result) in
            if let dictionary = result as? [String: Any], let error = dictionary["error"]{
                assert(false, "error = \(error)")
            }

            if let users = result as? [[String: [String: Any]]], let identity = users.first?.first?.key{

                let value = [String: Any]()
                let policy = 2
                let type = "Photo"

                let create = FlutterMethodCall.init(methodName: "objects", arguments: ["type": type, "value": value, "policy": policy, "identity": identity, "databaseUrl": self.realmDatabasePath])
                    SwiftFlutterrealmPlugin().handle(create) { (result) in
                        if let dictionary = result as? [String: Any], let error = dictionary["error"]{
                            assert(false, "error = \(error)")
                        }

                        assert(result is [[String: Any]], "users result have not correct type")
                    }
            }else{
               assert(false, "users result have not correct type")
            }
        }
    }
    
    

    func testPerforsmanceExample() {
        // This is an example of a performance test case.
        measure {

            // Put the code you want to measure the time of here.
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {

            // Put the code you want to measure the time of here.
        }
    }

}

