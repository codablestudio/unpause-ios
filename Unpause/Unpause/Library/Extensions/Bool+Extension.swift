//
//  Bool+Extension.swift

//
//  Created by Marko Aras on 09/01/2019.
//  Copyright © 2019 Codable Studio. All rights reserved.
//

import Foundation

extension Bool {
    func stringValue() -> String {
        return self ? "true" : "false"
    }
}
