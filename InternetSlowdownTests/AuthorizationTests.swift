//
//  AuthorizationTests.swift
//  InternetSlowdownTests
//
//  Created by Mateo Ochoa on 2022-11-29.
//

import XCTest
@testable import InternetSlowdown

final class AuthorizationTests: XCTestCase {
    
    func testRightsExist() throws {
        let authStatus = AuthorizationRightGet(Authorization.slowdownAuthRightName, nil)
        XCTAssertTrue(authStatus == 0)
    }
}
