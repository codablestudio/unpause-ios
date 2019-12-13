//
//  UIScreen+Extension.swift

//
//  Created by Marko Aras on 12/11/2019.
//  Copyright © 2019 Codable Studio. All rights reserved.
//

import UIKit

extension UIScreen {
    static func getWidth() -> CGFloat {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return UIScreen.main.bounds.width
        }
        return min(UIScreen.main.bounds.width, 414)
    }
    
    static func getHeight() -> CGFloat {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return UIScreen.main.bounds.height
        }
        return min(UIScreen.main.bounds.height, 896)
    }
}
