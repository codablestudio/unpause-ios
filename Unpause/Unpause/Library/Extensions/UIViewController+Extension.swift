//
//  UIViewController+Extension.swift

//
//  Created by Marko Aras on 17/09/2018.
//  Copyright © 2018 Codable Studio. All rights reserved.
//

import UIKit

// MARK: - Window elements heights
extension UIViewController {
    func getNavigationPlusStatusBarHeight() -> CGFloat {
        return getStatusBarHeight() + getNavigationBarHeight()
    }

    func getStatusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    func getNavigationBarHeight() -> CGFloat {
        if let navBarHeight = self.navigationController?.navigationBar.bounds.height {
            return navBarHeight
        }
        return 0
    }
    
    func safeBottomInset() -> CGFloat {
        let window = UIApplication.shared.keyWindow
        return window?.safeAreaInsets.bottom ?? 0
    }
    
    /// returns safeBottomInset if > 0, else return returns 10
    func safeButtonBottomInset() -> CGFloat {
        let window = UIApplication.shared.keyWindow
        let bottom = window?.safeAreaInsets.bottom ?? 0
        return bottom > 0 ? bottom : 10
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController {
    @objc func viewDidLoadLogging() {
//        print("Showing VC 👻: \(type(of: self))")
        self.viewDidLoadLogging()
    }
    
    static func printViewControllerInfo() {
        let viewController: AnyClass? = NSClassFromString("UIViewController")
        method_exchangeImplementations(
            // swiftlint:disable:next force_unwrapping
            class_getInstanceMethod(viewController, #selector(UIViewController.viewDidLoad))!,
            // swiftlint:disable:next force_unwrapping
            class_getInstanceMethod(viewController, #selector(UIViewController.viewDidLoadLogging))!
        )
    }
    
    func popTwoControllersBack() {
        if let viewControllers = self.navigationController?.viewControllers, viewControllers.count - 3 >= 0 {
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        } else {
            print("CAN'T popTwoControllersBack")
        }
    }
    
    func showOneOptionAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
