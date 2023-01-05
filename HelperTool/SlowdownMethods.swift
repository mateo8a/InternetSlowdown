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
        let slowdownSetup = SlowdownSetup.shared
        slowdownSetup.setUpPfFile()
        slowdownSetup.setUpDnPipe()
        slowdownSetup.setUpAnchorFile()
        slowdownSetup.enableFirewall()
        slowdownSetup.loadDummynetAnchor()
        slowdownSetup.configDnPipe(pipeConf: pipeConf)
    }
    
    static func stopSlowdown() {
        let slowdownSetup = SlowdownSetup.shared
        slowdownSetup.deleteDnPipe()
        slowdownSetup.disableFirewall()
    }
    
    static func restartSlowdown(pipeConf: SlowdownType) {
        let slowdownSetup = SlowdownSetup.shared
        slowdownSetup.setUpDnPipe()
        slowdownSetup.setUpAnchorFile()
        slowdownSetup.enableFirewall()
        slowdownSetup.loadDummynetAnchor()
        slowdownSetup.configDnPipe(pipeConf: pipeConf)
    }
}
