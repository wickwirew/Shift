//
//  TransitionView.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

public final class ViewContext {
    
    let view: UIView
    var match: UIView?
    var snapshot: Snapshot?
    var initialState: ViewState
    var finalState: ViewState
    var options: ShiftViewOptions
    var superview: Superview
    var matchOriginalAlpha: CGFloat = 0
    let viewOriginalAlpha: CGFloat
    var reverseAnimations: Bool
    lazy var duration = calculateDuration()
    var discard = false
    
    init(toView: UIView,
         superview: Superview,
         reverseAnimations: Bool) {
        self.view = toView
        self.options = toView.shift
        self.viewOriginalAlpha = toView.alpha
        let finalState = ViewState(view: toView, superview: superview)
        self.initialState = finalState
        self.finalState = finalState
        self.superview = superview
        self.reverseAnimations = reverseAnimations
    }
    
    func takeSnapshot() {
        guard !options.isHidden else { return }
        
        if let match = match {
            snapshot = Snapshot(
                finalContent: reverseAnimations ? match : view,
                initialContent: reverseAnimations ? view : match,
                sizing: options.contentSizing,
                animation: options.contentAnimation
            )
        } else {
            snapshot = Snapshot(
                finalContent: view,
                initialContent: nil,
                sizing: options.contentSizing,
                animation: options.contentAnimation
            )
        }
        
        guard let snapshot = snapshot else { return }
        
        initialState.apply(to: snapshot, finalState: finalState)
        
        // Applying the initial state can cause the size to change,
        // so we need for relayout the snapshot
        snapshot.setNeedsLayout()
        snapshot.layoutIfNeeded()
        
        // Hide the view and its matching view
        match?.alpha = 0
        view.alpha = 0
    }
    
    func setMatch(to match: ViewContext, container: UIView) {
        self.match = match.view
        self.matchOriginalAlpha = match.view.alpha
        self.superview = .global(container)
        
        if reverseAnimations {
            self.finalState = ViewState(view: match.view, superview: superview)
        } else {
            self.initialState = ViewState(view: match.view, superview: superview)
        }
    }
    
    func addSnapshot() {
        guard let snapshot = snapshot else { return }
        
        switch superview {
        case .global(let container):
            container.addSubview(snapshot)
        case .parent(let parent):
            parent.snapshot?.addSubview(snapshot)
        }
    }
    
    func applyModifers() {
        guard match == nil else { return }
        
        if reverseAnimations {
            options.animations.apply(to: &finalState)
        } else {
            options.animations.apply(to: &initialState)
        }
    }
    
    func performCaAnimations() {
        addAnimation(value: \.position, layer: \.position)
        addAnimation(value: \.bounds, layer: \.bounds)
        addAnimation(value: \.cornerRadius, layer: \.cornerRadius)
        addAnimation(value: \.anchorPoint, layer: \.anchorPoint)
        addAnimation(value: \.zPosition, layer: \.zPosition)
        addAnimation(value: \.opacity, layer: \.opacity)
        addAnimation(value: \.isOpaque, layer: \.isOpaque)
        addAnimation(value: \.masksToBounds, layer: \.masksToBounds)
        addAnimation(value: \.borderColor, layer: \.borderColor)
        addAnimation(value: \.borderWidth, layer: \.borderWidth)
        addAnimation(value: \.contentsRect, layer: \.contentsRect)
        addAnimation(value: \.contentsScale, layer: \.contentsScale)
        addAnimation(value: \.shadowColor, layer: \.shadowColor)
        addAnimation(value: \.shadowOffset, layer: \.shadowOffset)
        addAnimation(value: \.shadowRadius, layer: \.shadowRadius)
        addAnimation(value: \.shadowOpacity, layer: \.shadowOpacity)
        addAnimation(value: \.transform, layer: \.transform)
        
        // A specialized addAnimation for shadowPath to default it if need be.
        if initialState.shadowPath != finalState.shadowPath {
            let fromPath = initialState.shadowPath ?? UIBezierPath(rect: initialState.bounds).cgPath
            let toPath = finalState.shadowPath ?? UIBezierPath(rect: finalState.bounds).cgPath
            snapshot?.layer.addAnimation(for: "shadowPath", from: fromPath, to: toPath, duration: duration)
            snapshot?.layer.shadowPath = toPath
        }
    }
    
    /// Adds an animation for the given keyPath if the value has changed.
    func addAnimation<T: Equatable>(value: KeyPath<ViewState, T>,
                                    layer: ReferenceWritableKeyPath<CALayer, T>) {
        let from = initialState[keyPath: value]
        let to = finalState[keyPath: value]
        
        // make sure the value has changed
        guard to != from else { return }
        
        snapshot?.layer.addAnimation(for: layer._kvcKeyPathString!, from: from, to: to, duration: duration)
        snapshot?.layer[keyPath: layer] = to
    }
    
    /// Performs the changes that should not be animated.
    /// Things like `masksToBounds` should be set before the
    /// animations are performed, so things like `cornerRadius` work.
    func performNonAnimatedChanges() {
        snapshot?.layer.zPosition = finalState.zPosition
        snapshot?.layer.masksToBounds = finalState.masksToBounds
    }
    
    /// Performs the animations that should be performed
    /// in a `UIView` animation block.
    func performUiViewAnimations() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(.normal)
        
        snapshot?.setContentAnimationStart()
        
        UIView.animate(
            withDuration: duration,
            animations: {
                self.snapshot?.layer.position = self.finalState.position
                self.snapshot?.alpha = self.finalState.alpha
                self.snapshot?.layer.bounds = self.finalState.bounds
                self.snapshot?.backgroundColor = self.finalState.backgroundColor
                self.snapshot?.setContentAnimationEnd()
                self.snapshot?.setNeedsLayout()
                self.snapshot?.layoutIfNeeded()
            }
        )

        CATransaction.commit()
    }
    
    func finish() {
        snapshot?.removeFromSuperview()
        
        // Show the view and its matching view
        match?.alpha = matchOriginalAlpha
        view.alpha = viewOriginalAlpha
    }
    
    /// Calculates an appropiate duration for the animation.
    func calculateDuration() -> TimeInterval {
        return 1.5
//        return 2
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

extension Array where Element == ViewContext {
    
    var maxDuration: TimeInterval {
        return self.map{ $0.duration }.max() ?? 0
    }
    
    var rootView: ViewContext? {
        return first
    }
}

enum Superview {
    
    case global(UIView)
    case parent(ViewContext)
    
    var coordinateSpace: UICoordinateSpace {
        switch self {
        case .global(let container):
            return container
        case .parent(let view):
            return view.view
        }
    }
}
