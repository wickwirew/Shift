//
//  UIViewController+Extensions.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @IBInspectable public var isTransitionEnabled: Bool {
        get { return shift.isEnabled }
        set { shift.isEnabled = newValue }
    }
}
