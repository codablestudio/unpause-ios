//
//  CGFloat+Extension.swift

//
//  Created by Marko Aras on 28/01/2019.
//  Copyright © 2019 Codable Studio. All rights reserved.
//

import UIKit

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }
    
    func between(_ lhs: CGFloat, _ rhs: CGFloat) -> Bool {
        return self > lhs && self < rhs
    }
}
