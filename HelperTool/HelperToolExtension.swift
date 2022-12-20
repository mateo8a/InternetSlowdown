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
    func startSlowdown(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String, pipeConf: HelperTool.TypeOfSlowdown) {
        ISLogger.logger.info("Starting slowdown from the helper tool side...")
        let isAuthorized = checkAuthorization(auth: auth, functionName: functionName)
        guard isAuthorized else {
            ISLogger.logger.error("User is not authorized to start slowdown.")
            return
        }
        ISLogger.logger.info("Daemon found authorization to start slowdown...")
        setUpPfFile()
        setUpAnchorFile()
        executeCommand(executable: .pfctl, args: .enableFirewall)
        setUpDnPipe()
        configDnPipe(pipeConf: pipeConf)
    }
    
    func stopSlowdown(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String) {
        ISLogger.logger.info("Stopping slowdown from the helper tool side...")
        executeCommand(executable: .pfctl, args: .disableFirewall)
    }
}

extension HelperTool {
    private enum ExecutablePaths: String {
        case pfctl = "/sbin/pfctl"
        case dnctl = "/usr/sbin/dnctl"
    }
    
    private enum Args {
        // pfctl commands
        case enableFirewall
        case disableFirewall
        // dnctl commands
        case findPipe(pipe: Int)
        case defaultConf(pipe: Int)
        case dialUp(pipe: Int)
        
        func toString() -> String {
            switch self {
            case .enableFirewall:
                return "-E -f /etc/pf.conf"
            case .disableFirewall:
                return "-d -f /etc/pf.conf"
            case .findPipe(pipe: let p):
                return "pipe show \(p)"
            case .defaultConf(pipe: let p):
                return "pipe \(p) config bw 700Kbit/s delay 1000ms"
            case .dialUp(pipe: let p):
                return "pipe \(p) config bw 56Kbit/s"
            }
        }
    }
    
    private func setUpPfFile() {
        let pfFilePath = URL(fileURLWithPath: "/etc/pf.conf")
        let f = try? String(contentsOf: pfFilePath, encoding: .utf8)
        var fileContents = f! // The pf.conf file should exist in all macs, so no risk in force unwrapping
        
        let dummynetAnchor = "dummynet-anchor \"com.mochoaco\""
        if fileContents.contains(dummynetAnchor) {
            return
        }
        fileContents += "\n\(dummynetAnchor)"
        try? fileContents.write(to: pfFilePath, atomically: true, encoding: .utf8)
    }
    
    private func setUpAnchorFile() {
        let anchorFilePath = "/etc/pf.anchors/com.mochoaco"
        let anchorRules = """
                          no dummynet quick on lo0 all
                          dummynet in proto tcp from any port 443 pipe 1
                          dummynet in proto tcp from any port 80 pipe 1
                          dummynet in proto udp from any port 443 pipe 1
                          dummynet in proto udp from any port 80 pipe 1
                          """
        do {
            try anchorRules.write(to: URL(fileURLWithPath: anchorFilePath), atomically: true, encoding: .utf8)
        } catch {
            ISLogger.logger.error("Could not write to the anchor file \(anchorFilePath)")
        }
    }
    
    func configDnPipe(pipeConf: HelperTool.TypeOfSlowdown) {
        switch pipeConf {
        case .defaultSlowdown:
            executeCommand(executable: .dnctl, args: .defaultConf(pipe: dnPipe))
        case .dialUp:
            executeCommand(executable: .dnctl, args: .dialUp(pipe: dnPipe))
        default:
            ISLogger.logger.error("Pipe configuration for option \(pipeConf.rawValue) does not exist")
        }
    }
    
    func setUpDnPipe() {
        var output = ""
        var i = 20
        while output == "" {
            output = executeCommand(executable: .dnctl, args: .findPipe(pipe: i))
            i += 1
        }
        dnPipe = i
    }
    
    // Taken from https://stackoverflow.com/questions/26971240/how-do-i-run-a-terminal-command-in-a-swift-script-e-g-xcodebuild
    private func executeCommand(executable: ExecutablePaths, args: Args) -> String {
        ISLogger.logger.info("Executing the slowdown command...")
        let task = Process()
        let swiftPipe = Pipe()
        
        task.standardOutput = swiftPipe
        task.standardError = swiftPipe
        task.arguments = args.toString().components(separatedBy: " ")
        task.executableURL = URL(fileURLWithPath: executable.rawValue)
        task.standardInput = nil
        
        do {
            try task.run()
        } catch {
            ISLogger.logger.error("Error during execution of command \(executable.rawValue)")
        }
        
        task.waitUntilExit()
        let data = swiftPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        ISLogger.logger.info("\(output, privacy: .public)")
        ISLogger.logger.info("Finished executing the slowdown command...")
        return output
    }
}
