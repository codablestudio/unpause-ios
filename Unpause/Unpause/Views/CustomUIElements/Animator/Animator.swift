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
    private let editShiftViewController: EditShiftViewController
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
            let editShiftViewController = secondViewController.topViewController as? EditShiftViewController,
            let selectedCell = activityViewController.selectedCell else {
                return nil
        }
        self.activityViewController = activityViewController
        self.editShiftViewController = editShiftViewController
        self.cellImageViewRect = selectedCell.containerView.convert(selectedCell.containerView.bounds, to: window)
    }
}

// MARK: - Animator animation and duration
extension Animator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let transitionContainerView = transitionContext.containerView
        
        guard let toView = secondViewController.view
            else {
                transitionContext.completeTransition(false)
                return
        }
        transitionContainerView.addSubview(toView)
        
        guard let selectedCell = activityViewController.selectedCell,
            let window = firstViewController.view.window ?? secondViewController.view.window,
            let cellContainerView = selectedCell.containerView.snapshotView(afterScreenUpdates: true),
            let editShiftViewControllerView = editShiftViewController.view.snapshotView(afterScreenUpdates: true)
            else {
                transitionContext.completeTransition(true)
                return
        }
        
        let isPresenting = type.isPresenting
        
        let backgroundView: UIView
        let fadeView = UIView(frame: transitionContainerView.bounds)
        fadeView.backgroundColor = secondViewController.view.backgroundColor
        
        if isPresenting {
            selectedCellContainerView = cellContainerView
            backgroundView = UIView(frame: transitionContainerView.bounds)
            backgroundView.addSubview(fadeView)
            fadeView.alpha = 0
        } else {
            backgroundView = firstViewController.view.snapshotView(afterScreenUpdates: true) ?? fadeView
            backgroundView.addSubview(fadeView)
        }
        toView.alpha = 0
        
        [backgroundView, selectedCellContainerView, editShiftViewControllerView].forEach { transitionContainerView.addSubview($0) }
        let editShiftViewControllerViewRect = editShiftViewController.view.convert((editShiftViewController.view.bounds), to: window)
        
        [selectedCellContainerView, editShiftViewControllerView].forEach {
            $0.frame = isPresenting ? cellImageViewRect : editShiftViewControllerViewRect
        }
        
        [selectedCellContainerView, editShiftViewControllerView].forEach {
            $0.frame = isPresenting ? cellImageViewRect : editShiftViewControllerViewRect
            $0.layer.cornerRadius = isPresenting ? 12 : 0
            $0.layer.masksToBounds = true
        }

        editShiftViewControllerView.alpha = isPresenting ? 0 : 1
        selectedCellContainerView.alpha = isPresenting ? 1 : 0
        
        UIView.animateKeyframes(withDuration: Self.duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.selectedCellContainerView.frame = isPresenting ? editShiftViewControllerViewRect : self.cellImageViewRect
                editShiftViewControllerView.frame = isPresenting ? editShiftViewControllerViewRect : self.cellImageViewRect
            }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.selectedCellContainerView.alpha = isPresenting ? 0 : 1
                editShiftViewControllerView.alpha = isPresenting ? 1 : 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                [editShiftViewControllerView, self.selectedCellContainerView].forEach {
                    $0.layer.cornerRadius = isPresenting ? 0 : 12
                    fadeView.alpha = isPresenting ? 1 : 0
                }
            }
        }, completion: { _ in
            self.selectedCellContainerView.removeFromSuperview()
            editShiftViewControllerView.removeFromSuperview()
            backgroundView.removeFromSuperview()
            toView.alpha = 1
            transitionContext.completeTransition(true)
        })
    }
}
