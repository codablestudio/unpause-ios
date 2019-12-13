//
//  UIScrollView+Extension.swift

//
//  Created by Marko Aras on 23/11/2018.
//  Copyright © 2018 Codable Studio. All rights reserved.
//

import UIKit
import RxSwift

extension UIScrollView {
    var currentPage: Int {
        return Int((self.contentOffset.x+(0.5 * self.frame.size.width)) / self.frame.width) + 1
    }
    
    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
    
    func hideIndicators() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    func showIndicators() {
        showsHorizontalScrollIndicator = true
        showsVerticalScrollIndicator = true
    }
}
