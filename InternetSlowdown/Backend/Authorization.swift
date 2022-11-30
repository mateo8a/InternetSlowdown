//
//  Authorization.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-25.
//

import Foundation

struct Authorization {
    static let kCommandKeyAuthRightName    = "authRightName"
    static let kCommandKeyAuthRightDefault = "authRightDefault"
    static let kCommandKeyAuthRightDesc    = "authRightDescription"

    static let commandInfo: Dictionary = {
        let AuthorizationRule: [NSString: NSString] = [
            "class": "user",
            "group": "admin",
            "timeout": "120", // 2 minutes
            "shared": "YES",
        ]

        let kAuthorizationRuleAuthenticateAsAdmin2MinTimeout = AuthorizationRule
        
        let sCommandInfo =
        [
            "functionName()":
                [
                    kCommandKeyAuthRightName    : "com.example.apple-samplecode.EBAS.readLicenseKey",
                    kCommandKeyAuthRightDefault : kAuthorizationRuleAuthenticateAsAdmin2MinTimeout,
                    kCommandKeyAuthRightDesc    : "InternetSlowdown is trying to ..."
                ]
        ]
        return sCommandInfo
    }()
    
    static func enumerateRightsUsingBlock(block: (_ authRightName: String, _ authRightDefault: Dictionary<String, Any>, _ authRightDesc: String) throws -> Void) throws {
        try commandInfo.forEach {
            (key: String, value: [String: Any]) in
            
            let authRightName    = value[kCommandKeyAuthRightName]! as! String
            let authRightDefault = value[kCommandKeyAuthRightDefault]! as! Dictionary<String, Any>
            let authRightDesc    = value[kCommandKeyAuthRightDesc]! as! String

            try block(authRightName, authRightDefault, authRightDesc)

        }
    }
    
    static func setupAuthorizationRights(authRef: AuthorizationRef) throws {
        print("Setting up rights:")
        try enumerateRightsUsingBlock {
            (authRightName: String, authRightDefault: Dictionary<String, Any>, authRightDesc: String) in
            
            var authStatus: OSStatus
            authStatus = AuthorizationRightGet(authRightName, nil)
            
            if authStatus == errAuthorizationDenied {
                authStatus = AuthorizationRightSet(
                    authRef,
                    authRightName,
                    authRightDefault as CFDictionary,
                    authRightDesc as CFString,
                    nil,
                    nil
                );
            }
            
            guard authStatus == errAuthorizationSuccess else {
                throw ISError.unableToSetupRights
            }
            return
        }
    }
}
