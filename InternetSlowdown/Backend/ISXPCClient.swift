//
//  XPCClient.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-22.
//

import Foundation
import Security

class ISXPCClient {

    // First, set up authorization
    // Then, connect to privileged helper tool (the daemon)
    
    var clientAuthRef: AuthorizationRef?
    var authorization = AuthorizationExternalForm()
//    var helperToolConnection: NSXPCConnection
    
    func setupAuthorization() throws {
        // Do not create external authorization reference if there is already one
        if authorizationExists(authorization) {
            return
        }
        
        // Create authorization reference
        var resultCode: OSStatus = AuthorizationCreate(nil, nil, AuthorizationFlags(), &clientAuthRef)
        
        guard (resultCode != errAuthorizationSuccess) else {
            let error: CFString = SecCopyErrorMessageString(resultCode, nil)!
            throw ISError.initialAuthorization(error)
        }
        
        // Create external authorization reference
        resultCode = AuthorizationMakeExternalForm(clientAuthRef!, &authorization);
        
        guard (resultCode != errAuthorizationSuccess) else {
            let error: CFString = SecCopyErrorMessageString(resultCode, nil)!
            throw ISError.externalAuthCreation(error)
        }
        
        // Set up authorization rights in the policy database
        guard (clientAuthRef != nil) else {
            throw ISError.noAuthorizationReference
        }
        try Authorization.setupAuthorizationRights(authRef: clientAuthRef!)
    }
    
    func connectToHelperTool() {
        do {
            try setupAuthorization()
        } catch ISError.initialAuthorization(let e) {
            ISLogger().cfStringError(with_message: "Initial authorization failed with error", error: e)
            return
        } catch ISError.externalAuthCreation(let e) {
            ISLogger().cfStringError(with_message: "External authorization creation failed with error", error: e)
            return
        } catch {
            ISLogger().errorError(with_message: "Initial authorization failed with error", error: error)
            return
        }
    }
    
    func authorizationExists(_ auth: AuthorizationExternalForm) -> Bool {
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
