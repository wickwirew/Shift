//
//  ModalTransitionPresenting.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

public class ModalTransitionPresenting: NSObject, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.375
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        
        transitionContext.containerView.insertSubview(toViewController.view, at: 0)
 
        let frame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.frame = frame
        toViewController.view.setNeedsLayout()
        toViewController.view.layoutIfNeeded()
        
        let animator = Animator(
            fromView: fromViewController,
            toView: toViewController,
            container: transitionContext.containerView,
            isPresenting: true
        )
        
        animator.animate { complete in
            toViewController.view.alpha = 1
            transitionContext.completeTransition(complete)
        }
    }
}
