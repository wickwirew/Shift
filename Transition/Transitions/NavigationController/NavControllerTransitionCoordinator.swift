//
//  NavControllerTransitionCoordinator.swift
//  Transition
//
//  Created by Wes Wickwire on 10/30/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

final class NavControllerTransitionCoordinator: NSObject, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return NavControllerTrasntitionPresenting()
        case .pop:
            return NavControllerTrasntitionDismissing()
        default:
            return nil
        }
    }
}
