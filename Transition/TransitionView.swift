//
//  TransitionView.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

final class TransitionView {
    
    weak var fromView: UIView?
    weak var toView: UIView?
    var snapshot: UIView?
    let initialState: TransitionViewState
    let finalState: TransitionViewState
    let location: ViewLocation
    
    lazy var duration: TimeInterval = calculateDuration()
    
    init(fromView: UIView,
         toView: UIView,
         location: ViewLocation,
         container: UIView) {
        self.fromView = fromView
        self.toView = toView
        self.initialState = TransitionViewState(view: fromView, container: container)
        self.finalState = TransitionViewState(view: toView, container: container)
        self.location = location
    }
    
    func takeSnapshot(container: UIView) {
        guard let view = fromView else { return }
        
        let oldCornerRadius = view.layer.cornerRadius
        let oldAlpha = view.alpha
        let oldShadowRadius = view.layer.shadowRadius
        let oldShadowOffset = view.layer.shadowOffset
        let oldShadowPath = view.layer.shadowPath
        let oldShadowOpacity = view.layer.shadowOpacity
        
        view.layer.cornerRadius = 0
        view.alpha = 1
        view.layer.shadowRadius = 0.0
        view.layer.shadowOffset = .zero
        view.layer.shadowPath = nil
        view.layer.shadowOpacity = 0.0
        
        snapshot = view.snapshot()
        
        view.layer.cornerRadius = oldCornerRadius
        view.alpha = oldAlpha
        view.layer.shadowRadius = oldShadowRadius
        view.layer.shadowOffset = oldShadowOffset
        view.layer.shadowPath = oldShadowPath
        view.layer.shadowOpacity = oldShadowOpacity
        
        guard let snapshot = snapshot else { return }
        initialState.apply(to: snapshot, finalState: finalState)
        
        // snapshots are taken in reverse order of when they
        // should be added back to the container view.
        // so it should be inserted at the bottom.
        container.insertSubview(snapshot, at: 0)
        
        fromView?.alpha = 0
        toView?.alpha = 0
    }
    
    func applyFinalState() {
        guard let snapshot = snapshot else { return }
        finalState.apply(to: snapshot)
    }
    
    func performCaAnimations() {
        addAnimation(key: .position, value: \.position, layer: \.position)
        addAnimation(key: .bounds, value: \.bounds, layer: \.bounds)
        addAnimation(key: .cornerRadius, value: \.cornerRadius, layer: \.cornerRadius)
        addAnimation(key: .anchorPoint, value: \.anchorPoint, layer: \.anchorPoint)
        addAnimation(key: .zPosition, value: \.zPosition, layer: \.zPosition)
        addAnimation(key: .opacity, value: \.opacity, layer: \.opacity)
        addAnimation(key: .isOpaque, value: \.isOpaque, layer: \.isOpaque)
        addAnimation(key: .masksToBounds, value: \.masksToBounds, layer: \.masksToBounds)
        addAnimation(key: .borderColor, value: \.borderColor, layer: \.borderColor)
        addAnimation(key: .borderWidth, value: \.borderWidth, layer: \.borderWidth)
        addAnimation(key: .contentsRect, value: \.contentsRect, layer: \.contentsRect)
        addAnimation(key: .contentsScale, value: \.contentsScale, layer: \.contentsScale)
        addAnimation(key: .shadowColor, value: \.shadowColor, layer: \.shadowColor)
        addAnimation(key: .shadowOffset, value: \.shadowOffset, layer: \.shadowOffset)
        addAnimation(key: .shadowRadius, value: \.shadowRadius, layer: \.shadowRadius)
        addAnimation(key: .shadowOpacity, value: \.shadowOpacity, layer: \.shadowOpacity)
        addAnimation(key: .transform, value: \.transform, layer: \.transform)
        
        // A specialized addAnimation for shadowPath to default it if need be.
        if initialState.shadowPath != finalState.shadowPath {
            let fromPath = initialState.shadowPath ?? UIBezierPath(rect: initialState.bounds).cgPath
            let toPath = finalState.shadowPath ?? UIBezierPath(rect: finalState.bounds).cgPath
            snapshot?.layer.addAnimation(for: .shadowPath, from: fromPath, to: toPath, duration: duration)
            snapshot?.layer.shadowPath = toPath
        }
    }
    
    /// Adds an animation for the given keyPath if the value has changed.
    func addAnimation<T: Equatable>(key: AnimationKeyPath,
                                    value: KeyPath<TransitionViewState, T>,
                                    layer: ReferenceWritableKeyPath<CALayer, T>) {
        let from = initialState[keyPath: value]
        let to = finalState[keyPath: value]
        
        // make sure the value has changed
        guard to != from else { return }
        
        snapshot?.layer.addAnimation(for: key, from: from, to: to, duration: duration)
        snapshot?.layer[keyPath: layer] = to
    }
    
    /// Performs the changes that should not be animated.
    /// Things like `masksToBounds` should be set before the
    /// animations are performed, so things like `cornerRadius` work.
    func performNonAnimatedChanges() {
        snapshot?.layer.zPosition = finalState.zPosition
        snapshot?.layer.masksToBounds = finalState.masksToBounds
    }
    
    /// Performs the animations that should not be performed
    /// in a `UIView` animation block.
    func performUiViewAnimations() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(.normal)
        
        UIView.animate(
            withDuration: duration,
            animations: {
                self.snapshot?.layer.position = self.finalState.position
                self.snapshot?.alpha = self.finalState.alpha
                self.snapshot?.layer.bounds = self.finalState.bounds
            }
        )

        CATransaction.commit()
    }
    
    func finish() {
        snapshot?.removeFromSuperview()
        fromView?.alpha = initialState.alpha
        toView?.alpha = finalState.alpha
    }
    
    /// Calculates an appropiate duration for the animation.
    func calculateDuration() -> TimeInterval {        // The max duration should be 0.375 seconds
        // The lowest should be 0.2 seconds
        // So there is an additional 0.175 seconds to add based off
        // how far the view is going to move or how much
        // it will change in size.
        let minDuration = 0.2
        let additionalDuration = 0.175
        
        let positionDistance = initialState.position.distance(to: finalState.position)
        let positionDuration = additionalDuration * TimeInterval(positionDistance.clamp(0, 500) / 500)
        
        return minDuration + positionDuration
    }
}
