//
//  UIColor+Extension.swift

//
//  Created by Marko Aras on 19/11/2018.
//  Copyright © 2018 Codable Studio. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var unpauseWhite: UIColor {
        return UIColor(named: "unpauseWhite") ?? UIColor.fallbackColor("unpauseWhite")
    }
    
    static var unpauseBlack: UIColor {
        return UIColor(named: "unpauseBlack") ?? UIColor.fallbackColor("unpauseBlack")
    }
    
    static var unpauseOrange: UIColor {
        return UIColor(named: "unpauseOrange") ?? UIColor.fallbackColor("unpauseOrange")
    }
    
    static var unpauseDarkGray: UIColor {
        return UIColor(named: "unpauseDarkGray") ?? UIColor.fallbackColor("unpauseDarkGray")
    }
    
    static var unpauseLightGray: UIColor {
        return UIColor(named: "unpauseLightGray") ?? UIColor.fallbackColor("unpauseLightGray")
    }
    
    static var unpauseGray: UIColor {
        return UIColor(named: "unpauseGray") ?? UIColor.fallbackColor("unpauseGray")
    }
    
    static var unpauseIndicatorGray: UIColor {
        return UIColor(named: "unpauseIndicatorGray") ?? UIColor.fallbackColor("unpauseIndicatorGray")
    }
    
    static func fallbackColor(_ forColor: String) -> UIColor {
        print("fallbackColor \(forColor)")
        return .red
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }
}
