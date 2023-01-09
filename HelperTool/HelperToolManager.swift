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
    var checkupTimer: Timer? = nil {
        willSet {
            if let ct = checkupTimer {
                ct.invalidate()
            }
        }
    }
            
    func helperToolDidLaunch() {
        ISSettings.shared.loadSettingsFromDisk()
        runSlowdownIfNecessary()
    }
    
    func runSlowdownIfNecessary() {
        let settings = ISSettings.shared
        if settings.settingsDict[ISSettings.slowdownIsActiveKey] == "\(true)" {
            if slowdownShouldStillRun() {
                let rawValue = Int(settings.settingsDict[ISSettings.slowdownTypeKey]!)
                let slowdownType = SlowdownType(rawValue: rawValue!)
                SlowdownMethods.restartSlowdown(pipeConf: slowdownType!)
            } else {
                settings.settingsDict[ISSettings.slowdownIsActiveKey] = "\(false)"
                self.unloadDaemon()
            }
        }
    }
    
    func startCheckupTimer() {
        checkupTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { timer in
            timer.tolerance = 0.75
            if !self.slowdownShouldStillRun() {
                SlowdownMethods.stopSlowdown()
                ISSettings.shared.settingsDict[ISSettings.slowdownIsActiveKey] = "\(false)"
                timer.invalidate()
                self.unloadDaemon()
            }
        }
    }
    
    func slowdownShouldStillRun() -> Bool {
        let settings = ISSettings.shared
        let endDate = try? Date(settings.settingsDict["EndDate"]!, strategy: .iso8601)
        return endDate! > Date.now
    }
    
    func unloadDaemon() {
        
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
