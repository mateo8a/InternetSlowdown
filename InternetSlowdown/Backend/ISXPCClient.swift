//
//  XPCClient.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-22.
//

import Foundation
import Security

class ISXPCClient {

    // Then, connect to privileged helper tool (the daemon)
    
    var clientAuthRef: AuthorizationRef?
    var authorization = AuthorizationExternalForm()
    var helperToolConnection: NSXPCConnection?
    
    func connectToHelperTool() {
        if helperToolConnection == nil {
            helperToolConnection = NSXPCConnection(machServiceName: HelperTool.machServiceName, options: NSXPCConnection.Options.privileged)

            helperToolConnection?.remoteObjectInterface = NSXPCInterface(with: HelperToolProtocol.self)
            helperToolConnection?.invalidationHandler = {
                () -> Void in
                ISLogger.warning(with_message: "Connection to helper tool was invalidated")
                self.helperToolConnection = nil
            }
            
            helperToolConnection?.interruptionHandler = {
                () -> Void in
                ISLogger.warning(with_message: "Connection to helper tool was interrupted")
                self.connectToHelperTool()
            }
            
            helperToolConnection?.resume()
        }
    }
}
