//
//  ModalTransitionPresenting.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

public class ModalTransitionPresenting: NSObject, UIViewControllerAnimatedTransitioning {
    let animator = Animator()
    
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
        
        self.animator.animate(
            fromView: fromViewController.view,
            toView: toViewController.view,
            container: transitionContext.containerView,
            options: Options(
                isPresenting: true,
                viewOrder: toViewController.shift.viewOrder,
                baselineDuration: toViewController.shift.baselineDuration,
                toViewControllerType: type(of: toViewController),
                fromViewControllerType: type(of: fromViewController),
                defaultAnimation: toViewController.shift.defaultAnimation
            ),
            completion: { complete in
                toViewController.view.alpha = 1
                transitionContext.completeTransition(complete)
            }
        )
    }
}
