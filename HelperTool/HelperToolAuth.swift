//
//  HelperToolAuth.swift
//  HelperTool
//
//  Created by Mateo Ochoa on 2023-01-05.
//

import Foundation

struct HelperToolAuth {
    private init() {}
    
    static func checkAuthorization(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String) -> Bool {
        var status: OSStatus? = nil
        var authRef: AuthorizationRef?
        let resultCode = AuthorizationCreateFromExternalForm(auth, &authRef)
        
        guard (resultCode == errAuthorizationSuccess) else {
            let error: CFString = SecCopyErrorMessageString(resultCode, nil)!
            ISLogger.logger.error("Failed to create authorization form from external auth form with error: \(error, privacy: .public)")
            return false
        }
        
        var authRights = AuthorizationRights()
        var rightName = (functionName as NSString).utf8String!
        var right = [AuthorizationItem(name: rightName, valueLength: 0, value: nil, flags: 0)]
        right.withUnsafeMutableBufferPointer { rightsBuff in
            var rightsPtr = UnsafeMutablePointer<AuthorizationItem>(mutating: rightsBuff.baseAddress!)
            authRights = AuthorizationRights(count: 1, items: rightsPtr)
            
            let myFlags: AuthorizationFlags = [.interactionAllowed, .extendRights]
            var authEnv = AuthorizationEnvironment()
            
            status = AuthorizationCopyRights(
                                           authRef!,
                                           &authRights,
                                           &authEnv,
                                           myFlags,
                                           nil
                                           )
        }
        return status == errAuthorizationSuccess
    }
}
