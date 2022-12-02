//
//  XPCClient.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-22.
//

import Foundation
import Security

class ISXPCClient {

    // First, set up authorization
    // Then, connect to privileged helper tool (the daemon)
    
    var clientAuthRef: AuthorizationRef?
    var authorization = AuthorizationExternalForm()
    var helperToolConnection: NSXPCConnection?
    
    func connectToHelperTool() {
        
    }
}
