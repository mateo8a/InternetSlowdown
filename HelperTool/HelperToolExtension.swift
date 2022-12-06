//
//  HelperToolExtension.swift
//  HelperTool
//
//  Created by Mateo Ochoa on 2022-12-03.
//

import Foundation

// Implement this here because HelperTool.swift is also part of the main app target
extension HelperTool {
    func checkAuthorization(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String) -> Bool {
        var authRef: AuthorizationRef?
        let resultCode = AuthorizationCreateFromExternalForm(auth, &authRef)
        
        guard (resultCode == errAuthorizationSuccess) else {
            let error: CFString = SecCopyErrorMessageString(resultCode, nil)!
            ISLogger.logger.error("Failed to create authorization form from external auth form with error: \(error)")
            return false
        }
        
        var rightName = (functionName as NSString).utf8String!
        let right = AuthorizationItem(name: rightName, valueLength: 0, value: nil, flags: 0)
        return true
    }
}

extension HelperTool: HelperToolProtocol {
    func startSlowdown(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String) {
        print("starting slowdown...")
        let isAuthorized = checkAuthorization(auth: auth, functionName: functionName)
        guard isAuthorized else {
            ISLogger.logger.error("User is not authorized to start slowdown.")
            return
        }
    }
}
