//
//  NavControllerTrasntitionDismissing.swift
//  Transition
//
//  Created by Wes Wickwire on 11/3/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

class NavControllerTrasntitionDismissing: NSObject, UIViewControllerAnimatedTransitioning {
    let delay: Bool
    let insertToView: Bool
    
    init(delay: Bool = false, insertToView: Bool = false) {
        self.delay = delay
        self.insertToView = insertToView
    }
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.375
    }
    
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        transitionContext.containerView.insertSubview(toViewController.view, at: 0)
        
        let animator = Animator(
            fromView: fromViewController,
            toView: toViewController,
            container: transitionContext.containerView,
            isPresenting: false
        )
        
        DispatchQueue.main.async {
            animator.animate { complete in
                fromViewController.view.removeFromSuperview()
                transitionContext.completeTransition(complete)
            }
        }
    }
}

