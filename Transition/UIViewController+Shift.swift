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
}

extension UIViewController {
    
    private struct Keys {
        static var shift = "shift"
        static var transitionDelegate = "transitionDelegate"
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
