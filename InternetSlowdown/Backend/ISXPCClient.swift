//
//  XPCClient.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-22.
//

import Foundation
import Security
import ServiceManagement

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
            
            helperToolConnection?.resume()
        }
    }
    
    func startSlowdown() {
        let daemon = helperToolConnection?.remoteObjectProxyWithErrorHandler {
            error in
            ISLogger.errorError(with_message: "Could not get the remote object via XPC due to the following error: ", error: error)
        } as? HelperToolProtocol
        
        daemon?.startSlowdown(auth: &Authorization.authorization, functionName: #function)
    }
    
    func installHelperTool() {
        // Check that the rights are written in the policy database
        let areRightsSetUp: Bool = Authorization.areRightsSetUp()
        if !areRightsSetUp {
            Authorization.setupAuthorizationWithErrors()
        }
        
        // Ensure that user has the rights to install the privileged helper tool
        let hasRights = userHasRightToInstallPrivilegedTool()
        guard (hasRights == errAuthorizationSuccess) else {
            ISLogger.warning(with_message: "User is not authorized to install privileged helper tool.")
            return
        }
        
        do {
            try SMAppService.daemon(plistName: "com.mochoaco.InternetSlowdownd.plist").register()
        } catch {
            ISLogger.errorError(with_message: "Daemon could not be installed due to the following error: ", error: error)
        }
    }
    
    private func userHasRightToInstallPrivilegedTool() -> OSStatus {
        let blessRight = AuthorizationItem(name: (kSMRightBlessPrivilegedHelper as NSString).utf8String!, valueLength: 0, value: nil, flags: 0)
        let slowdownRight = AuthorizationItem(name: ("com.mochoaco.InternetSlowdown.slowdown" as NSString).utf8String!, valueLength: 0, value: nil, flags: 0)
        
        var rights = [blessRight, slowdownRight]
        var authRights = AuthorizationRights(count: 2, items: &rights)
        let myFlags: AuthorizationFlags = [.interactionAllowed, .extendRights]
        var authEnv = AuthorizationEnvironment()
        
        let status: OSStatus = AuthorizationCopyRights(
                                               Authorization.clientAuthRef!,
                                               &authRights,
                                               &authEnv,
                                               myFlags,
                                               nil
                                               )
        
        return status
    }
}
