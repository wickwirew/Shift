//
//  Animation.swift
//  ExpandoCell
//
//  Created by Wes Wickwire on 9/17/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import Foundation
import UIKit

private var shiftKey = "shift"
private var shiftTransitionDelegateKey = "shift.transitionDelegate"

public struct ShiftViewOptions: ShiftOptionsType {
    public var id: String?
    public var contentSizing: ContentSizing = .stretch
    public var contentAnimation: ContentAnimation = .none
    public var animations = [Animation]()
    public init() {}
}

public struct ShiftViewControllerOptions: ShiftOptionsType {
    public var isEnabled = false
    public init() {}
}

public protocol ShiftOptionsType {
    init()
}

extension UIView {
    
    public var shift: ShiftViewOptions {
        get {
            return getOrCreateOptions(key: &shiftKey, as: ShiftViewOptions.self)
        } set {
            setOptions(key: &shiftKey, to: newValue)
        }
    }
}

extension UIViewController {
    
    public var shift: ShiftViewControllerOptions {
        get {
            return getOrCreateOptions(key: &shiftKey, as: ShiftViewControllerOptions.self)
        } set {
            setOptions(key: &shiftKey, to: newValue)
            
            let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            
            guard newValue.isEnabled else {
                return objc_setAssociatedObject(
                    self,
                    &shiftTransitionDelegateKey,
                    nil,
                    nonatomic)
            }
            
            let existing = objc_getAssociatedObject(
                self,
                &shiftTransitionDelegateKey) as? ModalTransitioningDelegate
            
            guard existing == nil else { return }
            
            let delegate = ModalTransitioningDelegate()
            
            modalPresentationStyle = .custom
            transitioningDelegate = delegate
            modalTransitionStyle = .crossDissolve
            
            objc_setAssociatedObject(
                self,
                &shiftTransitionDelegateKey,
                delegate,
                nonatomic)
        }
    }
}

extension NSObject {
    
    func getOrCreateOptions<T: ShiftOptionsType>(key: inout String, as t: T.Type) -> T {
        if let value = objc_getAssociatedObject(self, &key) as? T {
            return value
        }
        
        let newValue = T()
        let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        objc_setAssociatedObject(self, &key, newValue, nonatomic)
        return newValue
    }
    
    func setOptions<T: ShiftOptionsType>(key: inout String, to newValue: T) {
        let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        objc_setAssociatedObject(self, &key, newValue, nonatomic)
    }
}
