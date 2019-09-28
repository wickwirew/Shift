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
        } else {
            return snapshotView(afterScreenUpdates: true)
        }
    }
}
