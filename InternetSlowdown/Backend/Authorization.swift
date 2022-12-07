//
//  Authorization.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-25.
//

import Foundation
import ServiceManagement

class Authorization {
    static var clientAuthRef: AuthorizationRef?
    static var authorization = AuthorizationExternalForm()
    
    // Sets up both the AuthorizationRef and the AuthorizationExternalForm:
    static func setupAuthorization() throws {
        if (clientAuthRef == nil || !authorizationExists(authorization)) {
            
            // Create authorization reference (AuthorizationRef)
            var resultCode: OSStatus = AuthorizationCreate(nil, nil, AuthorizationFlags(), &clientAuthRef)
            
            guard (resultCode == errAuthorizationSuccess) else {
                let error: CFString = SecCopyErrorMessageString(resultCode, nil)!
                throw ISError.initialAuthorization(error)
            }
            
            // Create external authorization reference (AuthorizationExternalForm)
            resultCode = AuthorizationMakeExternalForm(clientAuthRef!, &authorization);
            
            guard (resultCode == errAuthorizationSuccess) else {
                let error: CFString = SecCopyErrorMessageString(resultCode, nil)!
                throw ISError.externalAuthCreation(error)
            }
        }
        
        // Set up authorization rights in the policy database
        guard (clientAuthRef != nil) else {
            throw ISError.noAuthorizationReference
        }
        try Authorization.setupAuthorizationRights(authRef: clientAuthRef!)
    }
    
    static func setupAuthorizationWithErrors() {
        do {
            try setupAuthorization()
        } catch ISError.initialAuthorization(let e) {
            ISLogger.cfStringError(with_message: "Initial authorization failed with error", error: e)
            return
        } catch ISError.externalAuthCreation(let e) {
            ISLogger.cfStringError(with_message: "External authorization creation failed with error", error: e)
            return
        } catch {
            ISLogger.errorError(with_message: "Authorization set up failed with error", error: error)
            return
        }
    }
    
    private static func authorizationExists(_ auth: AuthorizationExternalForm) -> Bool {
        let authBytesAsArray: [UInt8] = {
            withUnsafeBytes(of: auth) { buf in
                return [UInt8](buf)
            }
        }()
        
        for i in authBytesAsArray {
            if !(i == 0) {
                return true
            }
        }
        return false
    }
}

extension Authorization {
    static func userHasRightToInstallPrivilegedTool() -> OSStatus {
        var status: OSStatus? = nil
        
        // Declaring the name as follows was informed by: https://github.com/confirmedcode/Confirmed-Mac/blob/master/ConfirmedProxy/HelperAuthorization.swift
        var blessRightName = (kSMRightBlessPrivilegedHelper as NSString).utf8String!
        let blessRight = AuthorizationItem(name: blessRightName, valueLength: 0, value: nil, flags: 0)
        
        var slowdownRightName = ("com.mochoaco.InternetSlowdown.slowdown" as NSString).utf8String!
        let slowdownRight = AuthorizationItem(name: slowdownRightName, valueLength: 0, value: nil, flags: 0)
        
        var rights = [blessRight, slowdownRight]
        var authRights = AuthorizationRights()
        
        // The following was informed by https://developer.apple.com/forums/thread/132252
        rights.withUnsafeMutableBufferPointer { rightsBuff in
            var rightsPtr = UnsafeMutablePointer<AuthorizationItem>(mutating: rightsBuff.baseAddress!)
            authRights = AuthorizationRights(count: 2, items: rightsPtr)
            
            let myFlags: AuthorizationFlags = [.interactionAllowed, .extendRights]
            var authEnv = AuthorizationEnvironment()
            
            status = AuthorizationCopyRights(
                                           clientAuthRef!,
                                           &authRights,
                                           &authEnv,
                                           myFlags,
                                           nil
                                           )
        }
        return status!
    }
}

// I put all the code regarding the rights in the policy database in this extension to keep things tidy
extension Authorization {
    static let kCommandKeyAuthRightName    = "authRightName"
    static let kCommandKeyAuthRightDefault = "authRightDefault"
    static let kCommandKeyAuthRightDesc    = "authRightDescription"
    static let slowdownAuthRightName       = "com.mochoaco.InternetSlowdown.slowdown"
    
    private static let commandInfo: Dictionary = {
        let kAuthorizationRuleAuthenticateAsAdmin2MinTimeout: [NSString: NSString] = [
            "class": "user",
            "group": "admin",
            "timeout": "120", // 2 minutes
            "shared": "YES",
        ]
        
        let sCommandInfo =
        [
            "startSlowdown()":
                [
                    kCommandKeyAuthRightName    : slowdownAuthRightName,
                    kCommandKeyAuthRightDefault : kAuthorizationRuleAuthenticateAsAdmin2MinTimeout,
                    kCommandKeyAuthRightDesc    : "Start slowdown"
                ]
        ]
        return sCommandInfo
    }()
    
    private static func enumerateRightsUsingBlock(block: (_ authRightName: String, _ authRightDefault: Dictionary<String, Any>, _ authRightDesc: String) throws -> Void) throws {
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
                )
                print("Attempting to set up rights in the policy database")
            }
            
            guard authStatus == errAuthorizationSuccess else {
                throw ISError.unableToSetupRights
            }
            print("Rights all set up")
        }
    }
    
    static func areRightsSetUp() -> Bool {
        var rightsSetUp: Bool?
        do {
            try enumerateRightsUsingBlock {
                (authRightName: String, authRightDefault: Dictionary<String, Any>, authRightDesc: String) in
                
                var authStatus: OSStatus
                authStatus = AuthorizationRightGet(authRightName, nil)
                if authStatus == errAuthorizationDenied {
                    rightsSetUp = false
                }
            }
            if rightsSetUp == nil {
                rightsSetUp = true
            }
        } catch {}
        return rightsSetUp!
    }
    
    #if DEBUG
    static func removeAuthorizationRights(authRef: AuthorizationRef) throws {
        try enumerateRightsUsingBlock {
            (authRightName: String, authRightDefault: Dictionary<String, Any>, authRightDesc: String) in
            let removedStatus: OSStatus = AuthorizationRightRemove(authRef, authRightName)
            guard (removedStatus == errAuthorizationSuccess) else {
                throw ISError.unableToRemoveRights
            }
        }

    }
    #endif
}
