//
//  HomeNetworkingMock.swift
//  UnpauseTests
//
//  Created by Krešimir Baković on 07/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

@testable import Unpause
import Foundation
import RxSwift
import Firebase

class HomeNetworkingMock: HomeNetworkingProtocol {
    func getUsersLastCheckInTime() -> Observable<LastCheckInResponse> {
        return Observable.just(LastCheckInResponse.success(nil))
    }
}
