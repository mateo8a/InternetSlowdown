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
    
    func applicationWillTerminate(_ notification: Notification) {
//    Uncomment when we want rights to be re-written to the policy database
//    #if DEBUG
//        do {
//            try Authorization.removeAuthorizationRights(authRef: xpc.clientAuthRef!)
//        } catch {
//            ISLogger().errorError(with_message: "Error while removing rights from policy database", error: error)
//            return
//        }
//    #endif
    }
}
