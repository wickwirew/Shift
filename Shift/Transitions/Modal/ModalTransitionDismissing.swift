//
//  ModalTransitionDismissing.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

public class ModalTransitionDismissing: NSObject, UIViewControllerAnimatedTransitioning {
    let animator = Animator()
    
    public func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.375
    }
    
    public func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) else { return }

        animator.animate(
            fromView: fromViewController.view,
            toView: toViewController.view,
            container: transitionContext.containerView,
            options: Options(
                isPresenting: false,
                viewOrder: fromViewController.shift.viewOrder,
                baselineDuration: fromViewController.shift.baselineDuration,
                toViewControllerType: type(of: toViewController),
                defaultAnimation: fromViewController.shift.defaultAnimation
            ),
            completion: { complete in
                fromViewController.view.removeFromSuperview()
                transitionContext.completeTransition(complete)
            }
        )
    }
}
