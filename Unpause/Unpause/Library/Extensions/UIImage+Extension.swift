//
//  UIImage+Extension.swift

//
//  Created by Marko Aras on 18/03/2019.
//  Copyright © 2019 Codable Studio. All rights reserved.
//

import UIKit

extension UIImage {
    static func create(_ named: String) -> UIImage {
        if let img = UIImage.init(named: named) {
            return img
        } else {
            // swiftlint:disable:next force_unwrapping
            fatalError()
        }
    }
}
