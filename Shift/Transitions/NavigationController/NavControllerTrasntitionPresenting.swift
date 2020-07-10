//
//  NavControllerTrasntitionPresenting.swift
//  Transition
//
//  Created by Wes Wickwire on 11/3/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

class NavControllerTrasntitionPresenting: NSObject, UIViewControllerAnimatedTransitioning {
    let animator = Animator()
    
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
        
        DispatchQueue.main.async {
            self.animator.animate(
                fromView: fromViewController.view,
                toView: toViewController.view,
                container: transitionContext.containerView,
                options: Options(
                    isPresenting: true,
                    viewOrder: toViewController.shift.viewOrder,
                    baselineDuration: toViewController.shift.baselineDuration,
                    toViewControllerType: type(of: toViewController)
                ),
                completion: { complete in
                    toViewController.view.alpha = 1
                    transitionContext.completeTransition(complete)
                }
            )
        }
    }
}

