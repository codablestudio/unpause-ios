//
//  PresentationType.swift
//  Unpause
//
//  Created by Krešimir Baković on 25/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum PresentationType {
    case present
    case dismiss

    var isPresenting: Bool {
        return self == .present
    }
}
