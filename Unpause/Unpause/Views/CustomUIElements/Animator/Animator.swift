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
    static let duration: TimeInterval = 0.25
    
    private let type: PresentationType
    private let firstViewController: CustomTabBarController
    private let secondViewController: UINavigationController
    private let activityViewController: ActivityViewController
    private let addShiftViewController: AddShiftViewController
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
            let addShiftViewController = secondViewController.topViewController as? AddShiftViewController,
            let selectedCell = activityViewController.selectedCell else {
                return nil
        }
        self.activityViewController = activityViewController
        self.addShiftViewController = addShiftViewController
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
        
        guard let selectedCell = activityViewController.selectedCell,
            let window = firstViewController.view.window ?? secondViewController.view.window,
            let cellImageSnapshot = selectedCell.containerView.snapshotView(afterScreenUpdates: true),
            let controllerImageSnapshot = addShiftViewController.view.snapshotView(afterScreenUpdates: true)
            else {
                transitionContext.completeTransition(true)
                return
        }
        
        let isPresenting = type.isPresenting
        
        if isPresenting {
            selectedCellContainerViewSnapshot = cellImageSnapshot
        }
        toView.alpha = 0
        
        [selectedCellContainerViewSnapshot, controllerImageSnapshot].forEach { containerView.addSubview($0) }
        let controllerImageViewRect = addShiftViewController.view.convert((addShiftViewController.view.bounds), to: window)
        
        [selectedCellContainerViewSnapshot, controllerImageSnapshot].forEach {
            $0.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
        }
        
        controllerImageSnapshot.alpha = isPresenting ? 0 : 1
        selectedCellContainerViewSnapshot.alpha = isPresenting ? 1 : 0
        
        UIView.animateKeyframes(withDuration: Self.duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.selectedCellContainerViewSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.selectedCellContainerViewSnapshot.alpha = isPresenting ? 0 : 1
                controllerImageSnapshot.alpha = isPresenting ? 1 : 0
            }
        }, completion: { _ in
            self.selectedCellContainerViewSnapshot.removeFromSuperview()
            controllerImageSnapshot.removeFromSuperview()
            toView.alpha = 1
            transitionContext.completeTransition(true)
        })
    }
}

private extension Animator {
    func fadeIn(viewToAnimate: UIView, withDuration duration: Double) {
        UIView.animate(withDuration: duration, animations: {
            viewToAnimate.alpha = 1.0
        })
    }
    
    func fadeOut(viewToAnimate: UIView, withDuration duration: Double) {
        UIView.animate(withDuration: duration, animations: {
            viewToAnimate.alpha = 0.0
        })
    }
}
