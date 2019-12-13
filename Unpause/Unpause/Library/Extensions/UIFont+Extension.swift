//
//  UIFont+Extension.swift

//
//  Created by Marko Aras on 19/12/2018.
//  Copyright © 2018 Codable Studio. All rights reserved.
//

import UIKit

extension UIFont {
    static func medium(ofSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "SFProText-Medium", size: ofSize) else {
            fatalError("Failed to load the CustomFont font.")
        }
        
        return customFont
    }
    
    static func regular(ofSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "SFProText-Regular", size: ofSize) else {
            fatalError("Failed to load the CustomFont font.")
        }
        
        return customFont
    }
    
    static func bold(ofSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "SFProText-Bold", size: ofSize) else {
            fatalError("Failed to load the CustomFont font.")
        }
        
        return customFont
    }
    
    static func heavy(ofSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "SFProText-Heavy", size: ofSize) else {
            fatalError("Failed to load the CustomFont font.")
        }
        
        return customFont
    }
    
    static func displayRegular(ofSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "SFProDisplay-Regular", size: ofSize) else {
            fatalError("Failed to load the CustomFont font.")
        }
        
        return customFont
    }
    
    static func diplsayBold(ofSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "SFProDisplay-Bold", size: ofSize) else {
            fatalError("Failed to load the CustomFont font.")
        }
        
        return customFont
    }
    
    static func displayHeavy(ofSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "SFProDisplay-Heavy", size: ofSize) else {
            fatalError("Failed to load the CustomFont font.")
        }
        
        return customFont
    }
    
    static func diplsayBlack(ofSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "SFProDisplay-Black", size: ofSize) else {
            fatalError("Failed to load the CustomFont font.")
        }
        
        return customFont
    }
    
    static func semibold(ofSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "SFProText-Semibold", size: ofSize) else {
            fatalError("Failed to load the CustomFont font.")
        }
        
        return customFont
    }
    
    static func italic(ofSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "SFProDisplay-Italic", size: ofSize) else {
            fatalError("Failed to load the CustomFont font.")
        }
        
        return customFont
    }
    
    static func semiboldItalic(ofSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "SFProText-SemiboldItalic", size: ofSize) else {
            fatalError("Failed to load the CustomFont font.")
        }
        
        return customFont
    }
    
    static func consolas(ofSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "Consolas", size: ofSize) else {
            fatalError("Failed to load the CustomFont font.")
        }
        
        return customFont
    }
    
    static func consolasBold(ofSize: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "Consolas-Bold", size: ofSize) else {
            fatalError("Failed to load the CustomFont font.")
        }
        
        return customFont
    }
    
    static func listAllFonts() {
        for family in UIFont.familyNames {
            
            let sName: String = family as String
            print("family: \(sName)")
            
            for name in UIFont.fontNames(forFamilyName: sName) {
                print("name: \(name as String)")
            }
        }
    }
}
