//
//  HelperToolManager.swift
//  HelperTool
//
//  Created by Mateo Ochoa on 2022-11-30.
//

import Foundation

class HelperToolManager: NSObject {
    override init() {
        super.init()
        let settings = ISSettings.shared
        settings.loadSettingsFromDisk()
        runSlowdownIfNecessary(settings)
    }
    
    func runSlowdownIfNecessary(_ settings: ISSettings) {
        if settings.settingsDict["SlowdownIsActive"] == "Yes" {
            let rawValue = Int(settings.settingsDict["SlowdownType"]!)
            let slowdownType = HelperTool.SlowdownType(rawValue: rawValue!)
            HelperTool().restartSlowdown(pipeConf: slowdownType!)
        }
    }
}

extension HelperToolManager: NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        let exportedObject = HelperTool()
        newConnection.exportedInterface = NSXPCInterface(with: HelperToolProtocol.self)
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
}
