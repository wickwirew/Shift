//
//  Animation.swift
//  ExpandoCell
//
//  Created by Wes Wickwire on 9/17/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    struct TransitionKeys {
        static var id = "transition.id"
    }
    
    public var transition: TransitionExtendable<UIView> {
        return TransitionExtendable(base: self)
    }
}

public class TransitionExtendable<Base> {
    let base: Base
    internal init(base: Base) {
        self.base = base
    }
}

extension TransitionExtendable where Base: UIView {
    
    public var id: String? {
        get {
            return objc_getAssociatedObject(base, &UIView.TransitionKeys.id) as? String
        } set {
            let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            objc_setAssociatedObject(base, &UIView.TransitionKeys.id, newValue, nonatomic)
        }
    }
}

extension TransitionExtendable where Base: UIViewController {
    
    public var isEnabled: Bool {
        get {
            return base.transitioningDelegate is ModalTransitioningDelegate
        } set {
            let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            
            guard newValue != false else {
                return objc_setAssociatedObject(
                    base,
                    &UIViewController.TransitionKeys.isEnabled,
                    newValue,
                    nonatomic)
            }
            
            let existing = objc_getAssociatedObject(
                base,
                &UIViewController.TransitionKeys.isEnabled) as? ModalTransitioningDelegate
            
            guard existing == nil else { return }
            
            let delegate = ModalTransitioningDelegate()
            
            base.modalPresentationStyle = .custom
            base.transitioningDelegate = delegate
            base.modalTransitionStyle = .crossDissolve
            
            objc_setAssociatedObject(
                base,
                &UIViewController.TransitionKeys.isEnabled,
                delegate,
                nonatomic)
        }
    }
}

extension UIViewController {
    
    struct TransitionKeys {
        static var isEnabled = "transition.isEnabled"
    }
    
    public var transition: TransitionExtendable<UIViewController> {
        return TransitionExtendable(base: self)
    }
}
