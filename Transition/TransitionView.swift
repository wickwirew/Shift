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
        
        snapshot = view.snapshotView(afterScreenUpdates: true)
        
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
        guard let snapshot = snapshot else { return }

        let from = initialState
        let to = finalState
        
        if from.cornerRadius != to.cornerRadius {
            snapshot.layer.addAnimation(for: .cornerRadius, from: from.cornerRadius, to: to.cornerRadius, duration: duration)
            snapshot.layer.cornerRadius = to.cornerRadius
        }
        
        if from.anchorPoint != to.anchorPoint {
            snapshot.layer.addAnimation(for: .anchorPoint, from: from.anchorPoint, to: to.anchorPoint, duration: duration)
            snapshot.layer.anchorPoint = to.anchorPoint
        }
        
        if from.zPosition != to.zPosition {
            snapshot.layer.addAnimation(for: .zPosition, from: from.zPosition, to: to.zPosition, duration: duration)
            snapshot.layer.zPosition = to.zPosition
        }
        
        if from.opacity != to.opacity {
            snapshot.layer.addAnimation(for: .opacity, from: from.opacity, to: to.opacity, duration: duration)
            snapshot.layer.opacity = to.opacity
        }
        
        if from.isOpaque != to.isOpaque {
            snapshot.layer.addAnimation(for: .isOpaque, from: from.isOpaque, to: to.isOpaque, duration: duration)
            snapshot.layer.isOpaque = to.isOpaque
        }
        
        if from.borderColor != to.borderColor {
            snapshot.layer.addAnimation(for: .borderColor, from: from.borderColor, to: to.borderColor, duration: duration)
            snapshot.layer.borderColor = to.borderColor
        }
        
        if from.borderWidth != to.borderWidth {
            snapshot.layer.addAnimation(for: .borderWidth, from: from.borderWidth, to: to.borderWidth, duration: duration)
            snapshot.layer.borderWidth = to.borderWidth
        }
        
        if from.contentsRect != to.contentsRect {
            snapshot.layer.addAnimation(for: .contentsRect, from: from.contentsRect, to: to.contentsRect, duration: duration)
            snapshot.layer.contentsRect = to.contentsRect
        }
        
        if from.contentsScale != to.contentsScale {
            snapshot.layer.addAnimation(for: .contentsScale, from: from.contentsScale, to: to.contentsScale, duration: duration)
            snapshot.layer.contentsScale = to.contentsScale
        }
        
        if from.shadowColor != to.shadowColor {
            snapshot.layer.addAnimation(for: .shadowColor, from: from.shadowColor, to: to.shadowColor, duration: duration)
            snapshot.layer.shadowColor = to.shadowColor
        }

        if from.shadowOffset != to.shadowOffset {
            snapshot.layer.addAnimation(for: .shadowOffset, from: from.shadowOffset, to: to.shadowOffset, duration: duration)
            snapshot.layer.shadowOffset = to.shadowOffset
        }

        if from.shadowRadius != to.shadowRadius {
            snapshot.layer.addAnimation(for: .shadowRadius, from: from.shadowRadius, to: to.shadowRadius, duration: duration)
            snapshot.layer.shadowRadius = to.shadowRadius
        }
        
        if from.shadowOpacity != to.shadowOpacity {
            snapshot.layer.addAnimation(for: .shadowOpacity, from: from.shadowOpacity, to: to.shadowOpacity, duration: duration)
            snapshot.layer.shadowOpacity = to.shadowOpacity
        }
        
        if from.shadowPath != to.shadowPath {
            let fromPath = from.shadowPath ?? UIBezierPath(rect: from.bounds).cgPath
            let toPath = to.shadowPath ?? UIBezierPath(rect: to.bounds).cgPath
            snapshot.layer.addAnimation(for: .shadowPath, from: fromPath, to: toPath, duration: duration)
            snapshot.layer.shadowPath = to.shadowPath
        }
        
        if from.transform != to.transform {
            snapshot.layer.addAnimation(for: .transform, from: from.transform, to: to.transform, duration: duration)
            snapshot.layer.transform = to.transform
        }
    }
    
    /// Adds a animation for the given keyPath if the value has changed.
    func addAnimation<T: Equatable>(key: AnimationKeyPath,
                                    value: KeyPath<TransitionViewState, T>,
                                    layer: ReferenceWritableKeyPath<CALayer, T>) {
        let to = initialState[keyPath: value]
        let from = finalState[keyPath: value]
        
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
    func calculateDuration() -> TimeInterval {
        // The max duration should be 0.375 seconds
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
