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
    private var selectedCellContainerView: UIView
    private let cellImageViewRect: CGRect
    
    init?(type: PresentationType, firstViewController: CustomTabBarController, secondViewController: UINavigationController, selectedCellContainerViewSnapshot: UIView) {
        self.type = type
        self.firstViewController = firstViewController
        self.secondViewController = secondViewController
        self.selectedCellContainerView = selectedCellContainerViewSnapshot
        
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
            let cellContainerView = selectedCell.containerView.snapshotView(afterScreenUpdates: true),
            let addShiftViewControllerView = addShiftViewController.view.snapshotView(afterScreenUpdates: true)
            else {
                transitionContext.completeTransition(true)
                return
        }
        
        let isPresenting = type.isPresenting
        
        let backgroundView: UIView
        let fadeView = UIView(frame: containerView.bounds)
        fadeView.backgroundColor = secondViewController.view.backgroundColor
        
        if isPresenting {
            selectedCellContainerView = cellContainerView
            backgroundView = UIView(frame: containerView.bounds)
            backgroundView.addSubview(fadeView)
            fadeView.alpha = 0
        } else {
            backgroundView = firstViewController.view.snapshotView(afterScreenUpdates: true) ?? fadeView
            backgroundView.addSubview(fadeView)
        }
        toView.alpha = 0
        
        [backgroundView, selectedCellContainerView, addShiftViewControllerView].forEach { containerView.addSubview($0) }
        let controllerImageViewRect = addShiftViewController.view.convert((addShiftViewController.view.bounds), to: window)
        
        [selectedCellContainerView, addShiftViewControllerView].forEach {
            $0.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
        }
        
        [selectedCellContainerView, addShiftViewControllerView].forEach {
            $0.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
            $0.layer.cornerRadius = isPresenting ? 12 : 0
            $0.layer.masksToBounds = true
        }

        addShiftViewControllerView.alpha = isPresenting ? 0 : 1
        selectedCellContainerView.alpha = isPresenting ? 1 : 0
        
        UIView.animateKeyframes(withDuration: Self.duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.selectedCellContainerView.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                addShiftViewControllerView.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                fadeView.alpha = isPresenting ? 1 : 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.selectedCellContainerView.alpha = isPresenting ? 0 : 1
                addShiftViewControllerView.alpha = isPresenting ? 1 : 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                [addShiftViewControllerView, self.selectedCellContainerView].forEach {
                    $0.layer.cornerRadius = isPresenting ? 0 : 12
                }
            }
        }, completion: { _ in
            self.selectedCellContainerView.removeFromSuperview()
            addShiftViewControllerView.removeFromSuperview()
            backgroundView.removeFromSuperview()
            toView.alpha = 1
            transitionContext.completeTransition(true)
        })
    }
}
