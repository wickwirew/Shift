//
//  ModalTransitionPresenting.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

class ModalTransitionPresenting: NSObject, UIViewControllerAnimatedTransitioning {
    
    let animator = TransitionAnimator()
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animator.duration
    }
    
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        
        // hide to view controller before it is added
        toViewController.view.isHidden = true

        transitionContext.containerView.insertSubview(toViewController.view, at: 0)
 
        let frame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.frame = frame
        toViewController.view.setNeedsLayout()
        toViewController.view.layoutIfNeeded()

        animator.animate(
            fromView: fromViewController.view,
            toView: toViewController.view,
            container: transitionContext.containerView,
            completion: { complete in
                toViewController.view.isHidden = false
                transitionContext.completeTransition(complete)
            }
        )
    }
}
