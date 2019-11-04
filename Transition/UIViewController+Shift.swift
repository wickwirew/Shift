//
//  File.swift
//  Transition
//
//  Created by Wes Wickwire on 10/7/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

public struct ShiftViewControllerOptions {
    public var modalTransition: ModalTransition?
    public var viewOrder: Options.ViewOrder = .sourceOnTop
    public var baselineDuration: TimeInterval?
}

extension UIViewController {
    
    private struct Keys {
        static var shift = "shift"
        static var transitionDelegate = "transitionDelegate"
        static var transitionCoordinator = "transitionCoordinator"
    }
    
    public var shift: ShiftViewControllerOptions {
        get {
            return getOrCreateAssociatedObject(
                key: &Keys.shift,
                as: ShiftViewControllerOptions.self,
                default: .init()
            )
        } set {
            setAssociatedObject(key: &Keys.shift, to: newValue)
            
            let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            
            guard newValue.modalTransition != nil else {
                return objc_setAssociatedObject(
                    self,
                    &Keys.transitionDelegate,
                    nil,
                    nonatomic)
            }
            
            if let nav = self as? UINavigationController {
                let existing = getAssociatedObject(
                    key: &Keys.transitionCoordinator,
                    as: TransitionCoordinator.self
                )
                
                guard existing == nil else { return }
                
                let coordinate = TransitionCoordinator()
                nav.delegate = coordinate
                setAssociatedObject(key: &Keys.transitionCoordinator, to: coordinate)
            } else {
                let existing = getAssociatedObject(
                    key: &Keys.transitionDelegate,
                    as: ModalTransitioningDelegate.self
                )
                
                guard existing == nil else { return }
                
                let delegate = ModalTransitioningDelegate()
                
                modalPresentationStyle = .custom
                transitioningDelegate = delegate
                modalTransitionStyle = .crossDissolve
                
                setAssociatedObject(key: &Keys.transitionDelegate, to: delegate)
            }
        }
    }
}
