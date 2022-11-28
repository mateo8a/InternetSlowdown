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
    
    func cfStringError(with_message message: String, error: CFString) {
        ISLogger.logger.error("\(message): \(error)")
    }
    
    func errorError<E: Error>(with_message message: String, error: E) {
        ISLogger.logger.error("\(message): \(error)")
    }
}
