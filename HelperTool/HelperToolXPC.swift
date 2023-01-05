//
//  HelperToolExtension.swift
//  HelperTool
//
//  Created by Mateo Ochoa on 2022-12-03.
//

import Foundation

// Daemon XPC methods
extension HelperTool: HelperToolProtocol {
    func startSlowdown(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String, pipeConf: SlowdownType, endDate: Date) {
        ISLogger.logger.info("Starting slowdown from the helper tool side...")
        let isAuthorized = HelperToolAuth.checkAuthorization(auth: auth, functionName: functionName)
        guard isAuthorized else {
            ISLogger.logger.error("User is not authorized to start slowdown.")
            return
        }
        ISLogger.logger.info("Daemon found authorization to start slowdown...")
        SlowdownMethods.startSlowdown(pipeConf: pipeConf)
        ISSettings.shared.updateSettings(pipeConf: pipeConf, endDate: endDate)
    }
    
    func stopSlowdown(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String) {
        ISLogger.logger.info("Stopping slowdown from the helper tool side...")
        SlowdownMethods.stopSlowdown()
    }
}
