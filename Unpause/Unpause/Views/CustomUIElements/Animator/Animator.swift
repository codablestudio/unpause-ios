//
//  Animator.swift
//  Unpause
//
//  Created by Krešimir Baković on 24/05/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import Foundation
import UIKit

class Animator: NSObject {
    static let duration: TimeInterval = 1.25
    
    private let type: PresentationType
    private let firstViewController: CustomTabBarController
    private let secondViewController: UINavigationController
    private var selectedCellContainerViewSnapshot: UIView
    private let cellImageViewRect: CGRect
    
    init?(type: PresentationType, firstViewController: CustomTabBarController, secondViewController: UINavigationController, selectedCellContainerViewSnapshot: UIView) {
        self.type = type
        self.firstViewController = firstViewController
        self.secondViewController = secondViewController
        self.selectedCellContainerViewSnapshot = selectedCellContainerViewSnapshot
        
        guard let window = firstViewController.view.window ?? secondViewController.view.window,
            let activityNavigationController = firstViewController.selectedViewController as? UINavigationController,
            let activityViewController = activityNavigationController.topViewController as? ActivityViewController,
            let selectedCell = activityViewController.selectedCell else {
                return nil
        }
        self.cellImageViewRect = selectedCell.containerView.convert(selectedCell.containerView.bounds, to: window)
    }
}

// MARK: - Animator animation and duration
extension Animator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toView = secondViewController.view
            else {
                transitionContext.completeTransition(false)
                return
        }
        containerView.addSubview(toView)
        transitionContext.completeTransition(true)
    }
}
