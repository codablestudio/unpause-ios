//
//  UILabel+Extension.swift

//
//  Created by Marko Aras on 18/09/2018.
//  Copyright © 2018 Codable Studio. All rights reserved.
//

import UIKit

extension UILabel {
    func setFontAndColor(font: UIFont, color: UIColor) {
        self.font = font
        self.textColor = color
    }
    
    func setLineHeight(lineHeight: CGFloat) {
        guard let text = self.text else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = self.textAlignment
        
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(NSAttributedString.Key.font,
                                value: self.font ?? UIFont.regular(ofSize: 16),
                                range: NSRange(location: 0, length: attrString.length))
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                value: paragraphStyle,
                                range: NSRange(location: 0, length: attrString.length))
        self.attributedText = attrString
    }
    
    func setLineSpacingAndHeightMultiple(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        
        let attributedString: NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle,
                                      range: NSRange(location: 0, length: attributedString.length))
        
        self.attributedText = attributedString
    }
    
    func boldedText(boldText: String, boldTextFont: UIFont, normalText: String,
                    normalTextFont: UIFont, color: UIColor, normalColor: UIColor? = nil) {
        let normalTextColor = normalColor ?? color
        self.setFontAndColor(font: normalTextFont, color: normalTextColor)
        let attrs = [NSAttributedString.Key.font: boldTextFont, NSAttributedString.Key.foregroundColor: color]
        
        let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
        
        let normalString = NSMutableAttributedString(string: normalText)
        
        attributedString.append(normalString)
        
        self.attributedText = attributedString
    }
    
    func boldedTextAfterRegular(boldText: String, boldTextFont: UIFont, normalText: String,
                                normalTextFont: UIFont, color: UIColor, normalColor: UIColor? = nil,
                                lineHeight: CGFloat = 1) {
        let normalTextColor = normalColor ?? color
        self.setFontAndColor(font: normalTextFont, color: normalTextColor)
        let attrs = [NSAttributedString.Key.font: boldTextFont, NSAttributedString.Key.foregroundColor: color]
        
        let attributedString = NSMutableAttributedString(string: "")
        let normalString = NSMutableAttributedString(string: normalText)
        normalString.applyLineHeight(lineHeight, font: normalTextFont)
        attributedString.append(normalString)
        
        let boldedString = NSMutableAttributedString(string: boldText, attributes: attrs)
        boldedString.applyLineHeight(lineHeight, font: boldTextFont)
        attributedString.append(boldedString)
        
        self.attributedText = attributedString
    }
    
    // swiftlint:disable:next function_parameter_count
    func boldTextInTheMiddle(firstPart: String, boldText: String, secondPart: String,
                             boldTextFont: UIFont, boldColor: UIColor, normalTextFont: UIFont,
                             normalColor: UIColor, lineHeight: CGFloat = 1) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = self.textAlignment
        
        let normalAttrs = [NSAttributedString.Key.font: normalTextFont,
                           NSAttributedString.Key.foregroundColor: normalColor]
        let boldAttrs = [NSAttributedString.Key.font: boldTextFont, NSAttributedString.Key.foregroundColor: boldColor]
        let attributedString = NSMutableAttributedString(string: "")
        
        let normalString = NSMutableAttributedString(string: firstPart, attributes: normalAttrs)
        normalString.applyLineHeight(lineHeight, font: normalTextFont)
        attributedString.append(normalString)
        
        let boldedString = NSMutableAttributedString(string: boldText, attributes: boldAttrs)
        boldedString.applyLineHeight(lineHeight, font: boldTextFont)
        attributedString.append(boldedString)
        
        let normalStringTwo = NSMutableAttributedString(string: secondPart, attributes: normalAttrs)
        normalStringTwo.applyLineHeight(lineHeight, font: normalTextFont)
        attributedString.append(normalStringTwo)
        
        self.attributedText = attributedString
    }
    
    func underlinedText(mainText: String, textToUnderline: String, color: UIColor,
                        font: UIFont = .regular(ofSize: 18), lineHeight: CGFloat = 1) {
        self.setFontAndColor(font: font, color: color)
        let range = (mainText as NSString).range(of: textToUnderline)
        let attributedString = NSMutableAttributedString(string: mainText)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue, range: range)
        attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: color, range: range)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        attributedString.applyLineHeight(lineHeight, font: font)
        self.attributedText = attributedString
    }
    
    // swiftlint:disable:next function_parameter_count
    func multicolorText(mainText: String, secondText: String,
                        mainFont: UIFont, secondFont: UIFont,
                        mainColor: UIColor, secondColor: UIColor) {
        self.setFontAndColor(font: mainFont, color: mainColor)
        
        let attrs = [NSAttributedString.Key.font: secondFont, NSAttributedString.Key.foregroundColor: secondColor]
        
        let attributedString = NSMutableAttributedString(string: "")
        let normalString = NSMutableAttributedString(string: mainText)
        attributedString.append(normalString)
        
        let coloredString = NSMutableAttributedString(string: secondText, attributes: attrs)
        attributedString.append(coloredString)
        
        self.attributedText = attributedString
    }
}

extension NSMutableAttributedString {
    func applyLineHeight(_ lineHeight: CGFloat, font: UIFont) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        
        self.addAttribute(NSAttributedString.Key.font,
                          value: font,
                          range: NSRange(location: 0, length: self.length))
        
        self.addAttribute(NSAttributedString.Key.paragraphStyle,
                          value: paragraphStyle,
                          range: NSRange(location: 0, length: self.length))
    }
}

extension UILabel {
    func addLetterSpacing(kernValue: Double) {
        if let labelText = text, !labelText.isEmpty {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue,
                                          range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
