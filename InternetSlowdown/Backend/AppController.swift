//
//  AppController.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-22.
//

import Foundation
import Cocoa

class AppController: NSObject, NSApplicationDelegate {
    var xpc = ISXPCClient()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Running applicationDidFinishLaunching!")
        xpc.connectToHelperTool()
    }
    
    func startSlowdown() {
        
    }
}
