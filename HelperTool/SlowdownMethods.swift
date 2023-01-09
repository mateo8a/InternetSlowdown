//
//  SlowdownMethods.swift
//  HelperTool
//
//  Created by Mateo Ochoa on 2023-01-05.
//

import Foundation

struct SlowdownMethods {
    private init() {}
    
    static func startSlowdown(pipeConf: SlowdownType) {
        SlowdownSetup.setUpPfFile()
        SlowdownSetup.setUpDnPipe()
        SlowdownSetup.setUpAnchorFile()
        SlowdownSetup.enableFirewall()
        SlowdownSetup.loadDummynetAnchor()
        SlowdownSetup.configDnPipe(pipeConf: pipeConf)
        HelperToolManager.shared.startCheckupTimer()
    }
    
    static func stopSlowdown() {
        SlowdownSetup.deleteDnPipe()
        SlowdownSetup.disableFirewall()
    }
    
    static func restartSlowdown(pipeConf: SlowdownType) {
        SlowdownSetup.setUpDnPipe()
        SlowdownSetup.setUpAnchorFile()
        SlowdownSetup.enableFirewall()
        SlowdownSetup.loadDummynetAnchor()
        SlowdownSetup.configDnPipe(pipeConf: pipeConf)
        HelperToolManager.shared.startCheckupTimer()
    }
}
