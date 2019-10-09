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
        get { return shift.id }
        set { shift.id = newValue }
    }
    
    func snapshot() -> UIView? {
        if let imageView = self as? UIImageView {
            let view = UIImageView(image: imageView.image)
            view.frame = imageView.bounds
            view.contentMode = imageView.contentMode
            view.tintColor = imageView.tintColor
            view.backgroundColor = imageView.backgroundColor
            view.layer.magnificationFilter = imageView.layer.magnificationFilter
            view.layer.minificationFilter = imageView.layer.minificationFilter
            view.layer.minificationFilterBias = imageView.layer.minificationFilterBias
            return view
        } else if let effectView = self as? UIVisualEffectView {
            let view = UIVisualEffectView(effect: effectView.effect)
            view.frame = effectView.bounds
            return view
        } else {
            let oldCornerRadius = layer.cornerRadius
            let oldAlpha = alpha
            let oldShadowRadius = layer.shadowRadius
            let oldShadowOffset = layer.shadowOffset
            let oldShadowPath = layer.shadowPath
            let oldShadowOpacity = layer.shadowOpacity
            
            layer.cornerRadius = 0
            alpha = 1
            layer.shadowRadius = 0.0
            layer.shadowOffset = .zero
            layer.shadowPath = nil
            layer.shadowOpacity = 0.0
            
            let snapshot = snapshotView(afterScreenUpdates: true)
            
            layer.cornerRadius = oldCornerRadius
            alpha = oldAlpha
            layer.shadowRadius = oldShadowRadius
            layer.shadowOffset = oldShadowOffset
            layer.shadowPath = oldShadowPath
            layer.shadowOpacity = oldShadowOpacity
        
            return snapshot
        }
    }
}
