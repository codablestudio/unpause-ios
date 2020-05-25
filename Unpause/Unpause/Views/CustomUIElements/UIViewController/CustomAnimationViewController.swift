//
//  CustomAnimationViewController.swift
//  Unpause
//
//  Created by Krešimir Baković on 24/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

class CustomAnimationViewController: NSObject {
    private let animationDuration: Double
    private let animationType: AnimationType

    init(animationDuration: Double, animationType: AnimationType) {
        self.animationDuration = animationDuration
        self.animationType = animationType
    }
}

extension CustomAnimationViewController: UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from) else {
                transitionContext.completeTransition(false)
                return
        }

        switch animationType {
        case .present:
            transitionContext.containerView.addSubview(toViewController.view)
            presentAnimation(with: transitionContext, viewToAnimate: toViewController.view)
        case .dissmiss:
            print("Dissmis")
        }
    }

    func presentAnimation(with transitionCotext: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
        viewToAnimate.clipsToBounds = true
        viewToAnimate.transform = CGAffineTransform(scaleX: 0, y: 0)

        let duration = transitionDuration(using: transitionCotext)
        UIView.animate(withDuration: duration,
        animations: ({
         viewToAnimate.transform = CGAffineTransform(scaleX: 1, y: 1)
        }), completion: ({ _ in
            transitionCotext.completeTransition(true)
        }))
    }
}
