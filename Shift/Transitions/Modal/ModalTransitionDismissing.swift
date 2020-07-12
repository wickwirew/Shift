//
//  ModalTransitionDismissing.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

public class ModalTransitionDismissing: NSObject, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.375
    }
    
    public func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        let animator = Animator(
            fromView: fromViewController,
            toView: toViewController,
            container: transitionContext.containerView,
            isPresenting: false
        )
        
        animator.animate { complete in
            fromViewController.view.removeFromSuperview()
            transitionContext.completeTransition(complete)
        }
    }
}
