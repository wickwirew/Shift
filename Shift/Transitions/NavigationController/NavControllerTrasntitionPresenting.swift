//
//  NavControllerTrasntitionPresenting.swift
//  Transition
//
//  Created by Wes Wickwire on 11/3/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

class NavControllerTrasntitionPresenting: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.375
    }
    
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning) {
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
        
        DispatchQueue.main.async {
            animator.animate { complete in
                toViewController.view.alpha = 1
                transitionContext.completeTransition(complete)
            }
        }
    }
}

