//
//  HelperToolProtocol.swift
//  HelperTool
//
//  Created by Mateo Ochoa on 2022-11-30.
//

import Foundation

@objc protocol HelperToolProtocol {
    func startSlowdown(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String, pipeConf: HelperTool.SlowdownType)
    func stopSlowdown(auth: UnsafePointer<AuthorizationExternalForm>, functionName: String)
}
