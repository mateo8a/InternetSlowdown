//
//  SlowdownExecution.swift
//  HelperTool
//
//  Created by Mateo Ochoa on 2023-01-05.
//

import Foundation

class SlowdownExecuter {
    static let shared = SlowdownExecuter()
    
    private init() {}
    
    var dnPipe: Int = 0
    
    func setUpPfFile() {
        ISLogger.logger.info("Setting up pf.conf file...")
        let pfFilePath = URL(fileURLWithPath: "/etc/pf.conf")
        let dummynetAnchor = "dummynet-anchor \"com.mochoaco\"\n"
        let f = try? String(contentsOf: pfFilePath, encoding: .utf8)
        var fileContents = f! // The pf.conf file should exist in all macs, so I'm guessing there is no risk in force unwrapping
        
        if fileContents.contains(dummynetAnchor) { return }
        fileContents += "\n\(dummynetAnchor)"
        do {
            try fileContents.write(to: pfFilePath, atomically: true, encoding: .utf8)
        } catch {
            ISLogger.logger.error("Couldn't overwrite /etc/pf.conf file to include the dummynet anchor. Error: \(error)")
        }
    }
    
    func setUpAnchorFile() {
        ISLogger.logger.info("Setting up dummynet anchor file...")
        let anchorFilePath = "/etc/pf.anchors/com.mochoaco"
        let anchorRules = """
                          no dummynet quick on lo0 all
                          dummynet in proto tcp from any port 443 pipe \(dnPipe)
                          dummynet in proto tcp from any port 80 pipe \(dnPipe)
                          dummynet in proto udp from any port 443 pipe \(dnPipe)
                          dummynet in proto udp from any port 80 pipe \(dnPipe)
                          
                          """
        do {
            try anchorRules.write(to: URL(fileURLWithPath: anchorFilePath), atomically: true, encoding: .utf8)
        } catch {
            ISLogger.logger.error("Could not write to the anchor file \(anchorFilePath). Error: \(error)")
        }
    }
    
    func enableFirewall() {
        ISLogger.logger.info("Enabling firewall...")
        executeCommand(executable: .pfctl, args: .enableFirewall)
    }
    
    func disableFirewall() {
        ISLogger.logger.info("Disabling firewall...")
        executeCommand(executable: .pfctl, args: .disableFirewall)
    }
    
    func setUpDnPipe() {
        ISLogger.logger.info("Setting up dummynet pipe number variable...")
        if dnPipe == 0 { // This ensures that the dummynet pipe is modified only once, when its value is its default value (namely 0).
            var outputOfRunningDnctlCommand = "placeholder non-empty output"
            var i = 0
            while !outputOfRunningDnctlCommand.isEmpty {
                i += 1
                outputOfRunningDnctlCommand = executeCommand(executable: .dnctl, args: .findPipe(pipe: i))
            }
            dnPipe = i
        }
    }
    
    func loadDummynetAnchor() {
        ISLogger.logger.info("Loading dummynet anchor...")
        executeCommand(executable: .pfctl, args: .loadDummynetAnchor)
    }
    
    func configDnPipe(pipeConf: HelperTool.SlowdownType) {
        ISLogger.logger.info("Configuring dummynet pipe with dnctl...")
        switch pipeConf {
        case .defaultSlowdown:
            executeCommand(executable: .dnctl, args: .defaultConf(pipe: dnPipe))
        case .dialUp:
            executeCommand(executable: .dnctl, args: .dialUp(pipe: dnPipe))
        default:
            ISLogger.logger.error("Pipe configuration for option \(pipeConf.rawValue) does not exist")
        }
    }
    
    func deleteDnPipe() {
        executeCommand(executable: .dnctl, args: .deletePipe(pipe: dnPipe))
        dnPipe = 0
    }
    
    private enum ExecutablePaths: String {
        case pfctl = "/sbin/pfctl"
        case dnctl = "/usr/sbin/dnctl"
    }
    
    private enum Args {
        // pfctl commands
        case enableFirewall
        case disableFirewall
        case loadDummynetAnchor
        // dnctl commands
        case findPipe(pipe: Int)
        case deletePipe(pipe: Int)
        case defaultConf(pipe: Int)
        case dialUp(pipe: Int)
        
        func toString() -> String {
            switch self {
            case .enableFirewall:
                return "-E -f /etc/pf.conf"
            case .disableFirewall:
                return "-d -f /etc/pf.conf"
            case .loadDummynetAnchor:
                return "-a com.mochoaco -f /etc/pf.anchors/com.mochoaco"
            case .findPipe(pipe: let p):
                return "pipe show \(p)"
            case .deletePipe(pipe: let p):
                return "pipe delete \(p)"
            case .defaultConf(pipe: let p):
                return "pipe \(p) config bw 700Kbit/s delay 1000ms"
            case .dialUp(pipe: let p):
                return "pipe \(p) config bw 56Kbit/s"
            }
        }
    }
    
    // Taken from https://stackoverflow.com/questions/26971240/how-do-i-run-a-terminal-command-in-a-swift-script-e-g-xcodebuild
    private func executeCommand(executable: ExecutablePaths, args: Args) -> String {
        ISLogger.logger.info("Executing command \(executable.rawValue, privacy: .public) with args \(args.toString(), privacy: .public)...")
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
            ISLogger.logger.error("Error during execution of command \(executable.rawValue, privacy: .public). Error: \(error)")
        }
        
        task.waitUntilExit()
        let data = swiftPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        ISLogger.logger.info("Output: \(output, privacy: .public)")
        ISLogger.logger.info("Finished executing command  \(executable.rawValue, privacy: .public)...")
        return output
    }
}
