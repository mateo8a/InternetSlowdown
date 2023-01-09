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
    private var checkupTimer: Timer? = nil {
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
                ISLogger.logger.info("Slowdown is restarting (runSlowdownIfNecessary)...")
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
        ISLogger.logger.info("Timer is about to run")
        checkupTimer = Timer(timeInterval: 2.5, repeats: true) { timer in
            timer.tolerance = 0.75
            ISLogger.logger.info("Timer is running")
            if !self.slowdownShouldStillRun() {
                SlowdownMethods.stopSlowdown()
                ISSettings.shared.settingsDict[ISSettings.slowdownIsActiveKey] = "\(false)"
                timer.invalidate()
                self.unloadDaemon()
            }
        }
        RunLoop.current.add(checkupTimer!, forMode: .common)
    }
    
    func stopCheckupTimer() {
        checkupTimer?.invalidate()
        checkupTimer = nil
    }
    
    func slowdownShouldStillRun() -> Bool {
        let settings = ISSettings.shared
        let endDate = try? Date(settings.settingsDict["EndDate"]!, strategy: .iso8601)
        return endDate! > Date.now
    }
    
    func unloadDaemon() {
        // if `launchctl unload /Library/LaunchDaemons/com.mochoaco.InternetSlowdownd.plist` is used, the daemon won't restart for a new slowdown. It will restart only when the computer restarts/the user logs out and logs in again.
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
