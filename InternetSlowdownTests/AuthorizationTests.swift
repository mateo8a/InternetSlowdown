//
//  AuthorizationTests.swift
//  InternetSlowdownTests
//
//  Created by Mateo Ochoa on 2022-11-29.
//

import XCTest
@testable import InternetSlowdown

final class AuthorizationTests: XCTestCase {
    
    func testCommand() {
        var clientAuthRef: AuthorizationRef?
        AuthorizationCreate(nil, nil, AuthorizationFlags(), &clientAuthRef)
//        Authorization
    }
}
