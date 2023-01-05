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
        runSlowdownIfNecessary()
    }
    
    func runSlowdownIfNecessary() {
        let settings = ISSettings.shared
        if settings.settingsDict["SlowdownIsActive"] == "Yes" {
            let endDate = try? Date(settings.settingsDict["EndDate"]!, strategy: .iso8601)
            if Date.now > endDate! {
                settings.settingsDict["SlowdownIsActive"] = "No"
            } else {
                let rawValue = Int(settings.settingsDict["SlowdownType"]!)
                let slowdownType = SlowdownType(rawValue: rawValue!)
                SlowdownMethods.restartSlowdown(pipeConf: slowdownType!)
            }
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
