//
//  HelperTool.swift
//  HelperTool
//
//  Created by Mateo Ochoa on 2022-11-30.
//

import Foundation

class HelperTool {
    static let machServiceName = "com.mochoaco.InternetSlowdownd"
    var dnPipe: Int = 0
    
    @objc enum TypeOfSlowdown: Int {
        case defaultSlowdown
        case dialUp
    }
}
