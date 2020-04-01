//
//  SettingsViewModelProtocol.swift
//  Unpause
//
//  Created by Krešimir Baković on 01/04/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import RxSwift

protocol SettingsViewModelProtocol {
    var logOutButtonTapped: PublishSubject<Void> { get }
}
