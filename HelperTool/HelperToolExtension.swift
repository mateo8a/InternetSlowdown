//
//  HelperToolExtension.swift
//  HelperTool
//
//  Created by Mateo Ochoa on 2022-12-03.
//

import Foundation

// Implement this here because file HelperTool.swift is also part of the main app target
extension HelperTool {
    func checkAuthorization(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String) -> Bool {
        var status: OSStatus? = nil
        var authRef: AuthorizationRef?
        let resultCode = AuthorizationCreateFromExternalForm(auth, &authRef)
        
        guard (resultCode == errAuthorizationSuccess) else {
            let error: CFString = SecCopyErrorMessageString(resultCode, nil)!
            ISLogger.logger.error("Failed to create authorization form from external auth form with error: \(error)")
            return false
        }
        
        var authRights = AuthorizationRights()
        var rightName = (functionName as NSString).utf8String!
        var right = [AuthorizationItem(name: rightName, valueLength: 0, value: nil, flags: 0)]
        right.withUnsafeMutableBufferPointer { rightsBuff in
            var rightsPtr = UnsafeMutablePointer<AuthorizationItem>(mutating: rightsBuff.baseAddress!)
            authRights = AuthorizationRights(count: 1, items: rightsPtr)
            
            let myFlags: AuthorizationFlags = [.interactionAllowed, .extendRights]
            var authEnv = AuthorizationEnvironment()
            
            status = AuthorizationCopyRights(
                                           authRef!,
                                           &authRights,
                                           &authEnv,
                                           myFlags,
                                           nil
                                           )
        }
        return status == errAuthorizationSuccess
    }
}

extension HelperTool: HelperToolProtocol {
    
    enum ExecutablePaths: String {
        case pfctl = "/sbin/pfctl"
        case dnctl = "/usr/sbin/dnctl"
    }
    
    enum Commands: String {
        // pfctl commands
        case startSlowdown = "-E -f /etc/pf.conf"
        case stopSlowdown = "-d -f /etc/pf.conf"
        // dnctl commands
        case defaultConf = "pipe 1 config bw 700Kbit/s delay 1000ms"
        case dialUp = "pipe 1 config bw 56Kbit/s"
    }
    
    func startSlowdown(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String) {
        ISLogger.logger.info("Starting slowdown from the helper tool side...")
        let isAuthorized = checkAuthorization(auth: auth, functionName: functionName)
        guard isAuthorized else {
            ISLogger.logger.error("User is not authorized to start slowdown.")
            return
        }
        ISLogger.logger.info("Daemon found authorization to start slowdown...")
        executeCommand(executable: ExecutablePaths.pfctl, command: Commands.startSlowdown)
    }
    
    func stopSlowdown(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String) {
        ISLogger.logger.info("Stopping slowdown from the helper tool side...")
        executeCommand(executable: ExecutablePaths.pfctl, command: Commands.stopSlowdown)
    }
    
    // Taken from https://stackoverflow.com/questions/26971240/how-do-i-run-a-terminal-command-in-a-swift-script-e-g-xcodebuild
    func executeCommand(executable: ExecutablePaths, command: Commands) -> String {
        ISLogger.logger.info("Executing the slowdown command...")
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = command.rawValue.components(separatedBy: " ")
        task.executableURL = URL(fileURLWithPath: executable.rawValue)
        task.standardInput = nil
        
        do {
            try task.run()
        } catch {
            ISLogger.logger.info("Slowdown not working!")
        }
        
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        ISLogger.logger.info("\(output, privacy: .public)")
        ISLogger.logger.info("Finished executing the slowdown command...")
        return output
    }
}
