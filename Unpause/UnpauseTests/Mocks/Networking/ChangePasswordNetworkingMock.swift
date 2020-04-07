//
//  ChangePasswordNetworkingMock.swift
//  UnpauseTests
//
//  Created by Krešimir Baković on 07/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

@testable import Unpause
import Foundation
import RxSwift
import Firebase

class ChangePasswordNetworkingMock: ChangePasswordNetworkingProtocol {
    func updateCurrentUserPassword(_ oldPassword: String?, with newPassword: String?) -> Observable<Response> {
        return Observable.just(Response.success)
    }
}
