//
//  ChangePasswordNetworkingProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol ChangePasswordNetworkingProtocol {
    func updateCurrentUserPassword(_ oldPassword: String?, with newPassword: String?) -> Observable<Response>
}
