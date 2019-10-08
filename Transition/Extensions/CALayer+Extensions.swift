//
//  CALayer+Extensions.swift
//  ExpandoCell
//
//  Created by Wes Wickwire on 9/21/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

extension CALayer {
    
    func addAnimation(for keyPath: String,
                      from fromValue: Any?,
                      to toValue: Any?,
                      duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        animation.timingFunction = .normal
        add(animation, forKey: keyPath)
    }
}
