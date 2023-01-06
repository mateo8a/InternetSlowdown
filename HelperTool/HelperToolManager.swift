//
//  HelperToolManager.swift
//  HelperTool
//
//  Created by Mateo Ochoa on 2022-11-30.
//

import Foundation

class HelperToolManager: NSObject {
    override private init() {
        super.init()
        helperToolDidLaunch()
    }
    
    static let shared = HelperToolManager()
    
    var dnPipe = 0
    var secondsSinceLastUpdate = 0
    
    func helperToolDidLaunch() {
        ISSettings.shared.loadSettingsFromDisk()
        runSlowdownIfNecessary()
    }
    
    func runSlowdownIfNecessary() {
        let settings = ISSettings.shared
        if settings.settingsDict["SlowdownIsActive"] == "true" {
            let endDate = try? Date(settings.settingsDict["EndDate"]!, strategy: .iso8601)
            if Date.now > endDate! {
                settings.settingsDict["SlowdownIsActive"] = "false"
            } else {
                let rawValue = Int(settings.settingsDict["SlowdownType"]!)
                let slowdownType = SlowdownType(rawValue: rawValue!)
                SlowdownMethods.restartSlowdown(pipeConf: slowdownType!)
            }
        }
    }
    
    func startCheckupTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
            
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
