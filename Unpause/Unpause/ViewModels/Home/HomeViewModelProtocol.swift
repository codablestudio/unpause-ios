//
//  HomeViewModelProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol HomeViewModelProtocol {
    var usersLastCheckInTimeRequest: Observable<LastCheckInResponse>! { get }
    var checkInResponse: Observable<Response>! { get }
    var fetchingLastShift: Observable<Bool> { get }
    
    var userChecksIn: PublishSubject<Bool> { get }
}
