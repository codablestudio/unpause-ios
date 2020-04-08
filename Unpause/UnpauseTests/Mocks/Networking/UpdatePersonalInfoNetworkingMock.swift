//
//  UpdatePersonalInfoNetworkingMock.swift
//  UnpauseTests
//
//  Created by Krešimir Baković on 08/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

@testable import Unpause
import Foundation
import RxSwift
import Firebase

class UpdatePersonalInfoNetworkingMock: UpdatePersonalInfoNetworkingProtocol {
    func updateUserWith(newFirstName: String?, newLastName: String?) -> Observable<Response> {
        return Observable.just(Response.success)
    }
}
