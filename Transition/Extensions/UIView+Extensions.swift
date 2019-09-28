//
//  UIView+Extensions.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable public var transitionId: String? {
        get { return transition.id }
        set { transition.id = newValue }
    }
}
