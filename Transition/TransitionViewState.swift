//
//  TransitionViewState.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

struct TransitionViewState {
    
    let position: CGPoint
    let bounds: CGRect
    let alpha: CGFloat
    let cornerRadius: CGFloat
    let anchorPoint: CGPoint
    let zPosition: CGFloat
    let opacity: Float
    let isOpaque: Bool
    let masksToBounds: Bool
    let borderColor: CGColor?
    let borderWidth: CGFloat
    let contentsRect: CGRect
    let contentsScale: CGFloat
    let shadowColor: CGColor?
    let shadowOffset: CGSize
    let shadowRadius: CGFloat
    let shadowOpacity: Float
    let shadowPath: CGPath?
    let transform: CATransform3D
    let backgroundColor: UIColor?
    
    init(view: UIView, container: UIView) {
        self.position = container.convert(view.layer.position, from: view.superview!)
        self.bounds = view.bounds
        self.cornerRadius = view.layer.cornerRadius
        self.anchorPoint = view.layer.anchorPoint
        self.zPosition = view.layer.zPosition
        self.opacity = view.layer.opacity
        self.isOpaque = view.layer.isOpaque
        self.masksToBounds = view.layer.masksToBounds
        self.borderColor = view.layer.borderColor
        self.borderWidth = view.layer.borderWidth
        self.contentsRect = view.layer.contentsRect
        self.contentsScale = view.layer.contentsScale
        self.shadowColor = view.layer.shadowColor
        self.shadowOffset = view.layer.shadowOffset
        self.shadowRadius = view.layer.shadowRadius
        self.shadowOpacity = view.layer.shadowOpacity
        self.shadowPath = view.layer.shadowPath
        self.transform = view.layer.transform
        self.alpha = view.alpha
        self.backgroundColor = view.backgroundColor
    }
    
    func apply(to view: UIView, finalState: TransitionViewState? = nil) {
        view.layer.position = position
        view.layer.cornerRadius = cornerRadius
        view.layer.anchorPoint = anchorPoint
        view.layer.zPosition = zPosition
        view.layer.opacity = opacity
        view.layer.isOpaque = isOpaque
        view.layer.masksToBounds = masksToBounds
        view.layer.borderColor = borderColor
        view.layer.borderWidth = borderWidth
        view.layer.contentsRect = contentsRect
        view.layer.contentsScale = contentsScale
        view.layer.shadowColor = shadowColor
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowOpacity = shadowOpacity
        view.alpha = alpha
        view.layer.bounds = bounds
        view.backgroundColor = backgroundColor
        
        // if it had a prior shadow path then make sure to default it
        // to the bounds if it is nil
        if finalState?.shadowPath != nil {
            view.layer.shadowPath = shadowPath ?? UIBezierPath(rect: bounds).cgPath
        } else {
            view.layer.shadowPath = shadowPath
        }
    }
}
