//
//  ISSettings.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2023-01-04.
//

import Foundation

class ISSettings {
    static let shared = ISSettings()
    
    private init() {}
    
    let settingsDirectoryPath = "/usr/local/etc/"
    var settingsFile: String {
        "\(settingsDirectoryPath)InternetSlowdownSettings"
    }
    var settingsDict: [String : String] = [:] {
        didSet {
            writeSettingsToDisk()
        }
    }
    static let endDateKey = "EndDate"
    static let slowdownTypeKey = "SlowdownType"
    static let slowdownIsActiveKey = "SlowdownIsActive"
    
    var defaultSettings: [String : String] = [
        ISSettings.endDateKey : "\(Date.distantPast.ISO8601Format())",
        ISSettings.slowdownTypeKey : "\(SlowdownType.defaultSlowdown.rawValue)",
        ISSettings.slowdownIsActiveKey : "false"
    ]
    
    func createSettingsFile() {
        let fileManager = FileManager()
        do {
            try fileManager.createDirectory(atPath: settingsDirectoryPath, withIntermediateDirectories: true)
            ISLogger.logger.info("Creation of folder at \(self.settingsDirectoryPath, privacy: .public)")
        } catch {
            ISLogger.logger.error("Error creating \(self.settingsDirectoryPath, privacy: .public) folder: \(error)")
        }
        if !fileManager.fileExists(atPath: settingsFile) {
            let success = fileManager.createFile(atPath: settingsFile, contents: nil)
            settingsDict = defaultSettings
            ISLogger.logger.info("Creation of settings file was \(success)")
        }
    }
    
    func writeSettingsToDisk() {
        // TODO: Look into using DispatchQueue.global or DispatchIO for this method
        do {
            let settingsAsJSON = try JSONSerialization.data(withJSONObject: settingsDict)
            try settingsAsJSON.write(to: URL(fileURLWithPath: settingsFile))
        } catch {
            ISLogger.logger.error("Error while writing settings to file: \(error)")
        }
        // Send notification through DistributedNotificationCenter so the UI gets updated if necessary
    }
    
    func loadSettingsFromDisk() {
        let settingsFileContent = FileManager().contents(atPath: settingsFile)
        if let sf = settingsFileContent {
            let jsonData = try? JSONSerialization.jsonObject(with: sf)
            settingsDict = jsonData as! [String : String]
        } else {
            createSettingsFile()
        }
    }
    
    func updateSettings(pipeConf: SlowdownType, endDate: Date, slowdownIsActive: Bool) {
        settingsDict[ISSettings.slowdownTypeKey] = "\(pipeConf.rawValue)"
        settingsDict[ISSettings.endDateKey] = "\(endDate.ISO8601Format())"
        settingsDict[ISSettings.slowdownIsActiveKey] = "\(slowdownIsActive)"
    }
}
