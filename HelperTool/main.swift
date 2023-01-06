//
//  main.swift
//  HelperTool
//
//  Created by Mateo Ochoa on 2022-11-24.
//

import Foundation

let delegate = HelperToolManager.shared
let listener = NSXPCListener(machServiceName: HelperTool.machServiceName)
listener.delegate = delegate;
listener.resume()
RunLoop.main.run()
