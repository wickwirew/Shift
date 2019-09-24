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

public extension TransitionExtendable where Base: UIView {
    
    var id: String? {
        get {
            return objc_getAssociatedObject(base, &UIView.TransitionKeys.id) as? String
        } set {
            let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            objc_setAssociatedObject(base, &UIView.TransitionKeys.id, newValue, nonatomic)
        }
    }
}
