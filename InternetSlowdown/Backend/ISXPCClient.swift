//
//  XPCClient.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-22.
//

import Foundation

class ISXPCClient {
    
    var helperToolConnection: NSXPCConnection?
    
    func connectToHelperTool() {
        if helperToolConnection == nil {
            helperToolConnection = NSXPCConnection(machServiceName: HelperTool.machServiceName, options: NSXPCConnection.Options.privileged)

            helperToolConnection?.remoteObjectInterface = NSXPCInterface(with: HelperToolProtocol.self)
            helperToolConnection?.invalidationHandler = {
                () -> Void in
                ISLogger.warning(with_message: "Connection to helper tool was invalidated. Setting connection to nil.")
                self.helperToolConnection = nil
            }
            
            helperToolConnection?.interruptionHandler = {
                () -> Void in
                ISLogger.warning(with_message: "Connection to helper tool was interrupted. Retrying connection...")
                self.connectToHelperTool()
            }
            ISLogger.logger.info("Connected to: \(self.helperToolConnection.debugDescription)")
            helperToolConnection?.resume()
        }
    }
    
    func startSlowdown(slowdownType: HelperTool.SlowdownType) {
        // First, connect to the helper tool
        connectToHelperTool()
        
        // Then, obtain the remote object and execute desired method
        let daemon = helperToolConnection?.remoteObjectProxyWithErrorHandler {
            error in
            ISLogger.errorError(with_message: "Error raised by remote object proxy during slowdown: ", error: error)
        } as? HelperToolProtocol
        
        ISLogger.logger.info("Client XPC's slowdown called. Daemon is: \(daemon.debugDescription)")
        daemon?.startSlowdown(auth: &Authorization.authorization, functionName: #function, pipeConf: slowdownType)
    }
    
    func stopSlowdown() {
        let daemon = helperToolConnection?.remoteObjectProxyWithErrorHandler {
            error in
            ISLogger.errorError(with_message: "Error raised by remote object proxy during slowdown: ", error: error)
        } as? HelperToolProtocol
        
        daemon?.stopSlowdown(auth: &Authorization.authorization, functionName: #function)
    }
}
