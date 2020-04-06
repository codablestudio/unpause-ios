//
//  MockUser.swift
//  UnpauseTests
//
//  Created by Krešimir Baković on 06/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

@testable import Unpause

class MockUser: User {
    static var existingUser: MockUser {
        return MockUser.init(firstName: "marko", lastName: "test", email: "valid@email.com")
    }
}
