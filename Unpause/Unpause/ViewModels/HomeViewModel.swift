//
//  HomeViewModel.swift
//  Unpause
//
//  Created by Krešimir Baković on 18/12/2019.
//  Copyright © 2019 Krešimir Baković. All rights reserved.
//

import Foundation

class HomeViewModel {
    
    private let signedInUserEmail: String
    
    init(signedInUserEmail: String) {
        self.signedInUserEmail = signedInUserEmail
    }
}
