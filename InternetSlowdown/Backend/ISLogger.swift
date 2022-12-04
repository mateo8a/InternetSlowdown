//
//  ISLogger.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-27.
//

import Foundation
import os.log

struct ISLogger {
    static let logger = Logger.init(subsystem: "com.mochoaco.internetslowdown", category: "main")
    
    static func cfStringError(with_message message: String, error: CFString) {
        ISLogger.logger.error("\(message): \(error)")
    }
    
    static func errorError<E: Error>(with_message message: String, error: E) {
        ISLogger.logger.error("\(message): \(error)")
    }
    
    static func warning(with_message message: String) {
        ISLogger.logger.warning("\(message)")
    }
}
