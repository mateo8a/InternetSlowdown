//
//  AuthorizationTests.swift
//  InternetSlowdownTests
//
//  Created by Mateo Ochoa on 2022-11-29.
//

import XCTest
@testable import InternetSlowdown

final class AuthorizationTests: XCTestCase {
    
    func testInitialSetupAuthorization() {
        // This is created when the app finishes launching
        // If authorization fails, then `clientAuthRef` remains nil and `authorization` is a bunch of zeros
        XCTAssertNotNil(Authorization.clientAuthRef)
        XCTAssertTrue(authorizationExists(Authorization.authorization))
    }
    
    func testRightsExist() throws {
        let authStatus = AuthorizationRightGet(Authorization.slowdownAuthRightName, nil)
        XCTAssertTrue(authStatus == 0)
    }
    
    func testAuthorizationIsAuthorizationExternalForm() {
        XCTAssertTrue(Authorization.authorization is AuthorizationExternalForm)
    }
    
    private func authorizationExists(_ auth: AuthorizationExternalForm) -> Bool {
        let authBytesAsArray: [UInt8] = {
            withUnsafeBytes(of: auth) { buf in
                return [UInt8](buf)
            }
        }()
        
        for i in authBytesAsArray {
            if !(i == 0) {
                return true
            }
        }
        return false
    }
}
