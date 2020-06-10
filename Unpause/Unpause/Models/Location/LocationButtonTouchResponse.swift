//
//  LocationButtonTouchResponse.swift
//  Unpause
//
//  Created by Krešimir Baković on 09/06/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation

enum LocationButtonTouchResponse {
    case newLocationSavedSuccessfully(String)
    case selectedLocationDeletedSuccessfully
    case error(UnpauseError)
}
