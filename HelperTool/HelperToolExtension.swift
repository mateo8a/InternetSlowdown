//
//  HelperToolExtension.swift
//  HelperTool
//
//  Created by Mateo Ochoa on 2022-12-03.
//

import Foundation

// Daemon XPC methods
extension HelperTool: HelperToolProtocol {
    func startSlowdown(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String, pipeConf: HelperTool.SlowdownType) {
        ISLogger.logger.info("Starting slowdown from the helper tool side...")
        let isAuthorized = checkAuthorization(auth: auth, functionName: functionName)
        guard isAuthorized else {
            ISLogger.logger.error("User is not authorized to start slowdown.")
            return
        }
        ISLogger.logger.info("Daemon found authorization to start slowdown...")
        let slowdownExecuter = SlowdownExecuter.shared
        slowdownExecuter.setUpPfFile()
        slowdownExecuter.setUpDnPipe()
        slowdownExecuter.setUpAnchorFile()
        slowdownExecuter.enableFirewall()
        slowdownExecuter.loadDummynetAnchor()
        slowdownExecuter.configDnPipe(pipeConf: pipeConf)
    }
    
    func stopSlowdown(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String) {
        ISLogger.logger.info("Stopping slowdown from the helper tool side...")
        let slowdownExecuter = SlowdownExecuter.shared
        slowdownExecuter.deleteDnPipe()
        slowdownExecuter.disableFirewall()
    }
}

// Non-XPC daemon methods
extension HelperTool {
    func restartSlowdown(pipeConf: HelperTool.SlowdownType) {
        ISLogger.logger.info("Restarting slowdown from the helper tool side...")
        let slowdownExecuter = SlowdownExecuter.shared
        slowdownExecuter.setUpDnPipe()
        slowdownExecuter.setUpAnchorFile()
        slowdownExecuter.enableFirewall()
        slowdownExecuter.loadDummynetAnchor()
        slowdownExecuter.configDnPipe(pipeConf: pipeConf)
    }

    private func checkAuthorization(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String) -> Bool {
        var status: OSStatus? = nil
        var authRef: AuthorizationRef?
        let resultCode = AuthorizationCreateFromExternalForm(auth, &authRef)
        
        guard (resultCode == errAuthorizationSuccess) else {
            let error: CFString = SecCopyErrorMessageString(resultCode, nil)!
            ISLogger.logger.error("Failed to create authorization form from external auth form with error: \(error)")
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
