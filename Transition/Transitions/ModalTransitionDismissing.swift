//
//  ModalTransitionDismissing.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

class ModalTransitionDismissing: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.375
    }
    
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        animate(
            fromView: fromViewController.view,
            toView: toViewController.view,
            container: transitionContext.containerView,
            isAppearing: false,
            middleware: [modalTransitionMiddlware(for: fromViewController)],
            completion: { complete in
                fromViewController.view.removeFromSuperview()
                transitionContext.completeTransition(complete)
            }
        )
    }
}
