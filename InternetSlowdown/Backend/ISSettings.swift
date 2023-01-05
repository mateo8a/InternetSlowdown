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
    var settingsDict: [String : String] = [:]
    
    func createSettingsFile() {
        let fileManager = FileManager()
        do {
            try fileManager.createDirectory(atPath: settingsDirectoryPath, withIntermediateDirectories: true)
            ISLogger.logger.info("Creation of folder at \(self.settingsDirectoryPath, privacy: .public)")
        } catch {
            ISLogger.logger.error("Error creating \(self.settingsDirectoryPath) folder: \(error)")
        }
        if !fileManager.fileExists(atPath: settingsFile) {
            let success = fileManager.createFile(atPath: settingsFile, contents: nil)
            settingsDict = defaultSettings
            writeSettingsToDisk()
            ISLogger.logger.info("Creation of settings file was \(success)")
        }
    }
    
    func writeSettingsToDisk() {
        do {
            let settingsAsJSON = try JSONSerialization.data(withJSONObject: settingsDict)
            try settingsAsJSON.write(to: URL(fileURLWithPath: settingsFile))
        } catch {
            ISLogger.logger.error("Error while writing settings to file: \(error)")
        }
        
    }
    
    var defaultSettings: [String : String] = [
        "EndTime" : "\(Date.distantPast.ISO8601Format())",
        "SlowdownType" : "\(SlowdownType.defaultSlowdown.rawValue)",
        "SlowdownIsActive" : "No"
    ]
    
    func loadSettingsFromDisk() {
        let settingsFileContent = FileManager().contents(atPath: settingsFile)
        if let sf = settingsFileContent {
            let jsonData = try? JSONSerialization.jsonObject(with: sf)
            settingsDict = jsonData as! [String : String]
        } else {
            createSettingsFile()
        }
    }
}
