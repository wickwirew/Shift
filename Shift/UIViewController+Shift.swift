//
//  File.swift
//  Transition
//
//  Created by Wes Wickwire on 10/7/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

public struct ShiftViewControllerOptions {
    public var enabled = false
    public var viewOrder: ViewOrder = .auto
    public var baselineDuration: TimeInterval?
    public var defaultAnimation: DefaultShiftAnimation? = DefaultAnimations.Fade()
    
    /// The view controller will now be presented via shift.
    public mutating func enable() {
        enabled = true
    }
    
    /// The view controller will no longer be presented via shift.
    public mutating func disable() {
        enabled = false
    }
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
            
            guard newValue.enabled else {
                return objc_setAssociatedObject(
                    self,
                    &Keys.transitionDelegate,
                    nil,
                    nonatomic)
            }
            
            if let nav = self as? UINavigationController {
                let existing = getAssociatedObject(
                    key: &Keys.transitionCoordinator,
                    as: NavControllerTransitionCoordinator.self
                )
                
                guard existing == nil else { return }
                
                let coordinate = NavControllerTransitionCoordinator()
                nav.delegate = coordinate
                setAssociatedObject(key: &Keys.transitionCoordinator, to: coordinate)
            }
            
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
