//
//  UIButton+Rx.swift

//
//  Created by Marko Aras on 12/11/2018.
//  Copyright © 2018 Codable Studio. All rights reserved.
//

//import RxSwift
//import RxCocoa
//
//extension Reactive where Base: BaseButton {
//    var animating: Binder<Bool> {
//        return Binder(self.base) { button, isAnimating in
//            if isAnimating {
//                button.isEnabled = false
//                button.startAnimating(.gray)
//            } else {
//                button.isEnabled = true
//                button.stopAnimating()
//            }
//        }
//    }
//    
//    var isEnabled: Binder<Bool> {
//        return Binder(self.base) { button, isEnabled in
//            button.isEnabled = isEnabled
//            button.isEnabledChanged()
//        }
//    }
//}
