//
//  ISErrror.swift
//  InternetSlowdown
//
//  Created by Mateo Ochoa on 2022-11-25.
//

import Foundation

enum ISError: Error {
    case initialAuthorization(CFString)
    case externalAuthCreation(CFString)
}
