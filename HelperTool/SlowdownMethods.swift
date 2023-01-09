//
//  SlowdownMethods.swift
//  HelperTool
//
//  Created by Mateo Ochoa on 2023-01-05.
//

import Foundation

struct SlowdownMethods {
    private init() {}
    
    static func startSlowdown(pipeConf: SlowdownType, endDate: Date) {
        SlowdownSetup.setUpPfFile()
        SlowdownSetup.setUpDnPipe()
        SlowdownSetup.setUpAnchorFile()
        SlowdownSetup.enableFirewall()
        SlowdownSetup.loadDummynetAnchor()
        SlowdownSetup.configDnPipe(pipeConf: pipeConf)
        
        HelperToolManager.shared.startCheckupTimer()
        ISSettings.shared.updateSettings(pipeConf: pipeConf, endDate: endDate, slowdownIsActive: true)
    }
    
    static func stopSlowdown() {
        SlowdownSetup.deleteDnPipe()
        SlowdownSetup.disableFirewall()
        
        HelperToolManager.shared.stopCheckupTimer()
        ISSettings.shared.updateSettings(endDate: Date.now, slowdownIsActive: false)
    }
    
    static func restartSlowdown(pipeConf: SlowdownType) {
        ISLogger.logger.info("Restarting slowdown...")
        SlowdownSetup.setUpDnPipe()
        SlowdownSetup.setUpAnchorFile()
        SlowdownSetup.enableFirewall()
        SlowdownSetup.loadDummynetAnchor()
        SlowdownSetup.configDnPipe(pipeConf: pipeConf)
        
        HelperToolManager.shared.startCheckupTimer()
    }
}
