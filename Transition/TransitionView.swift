//
//  TransitionView.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

final class TransitionView {
    
    let match: UIView?
    let view: UIView
    
    var snapshot: SnapshotView?
    
    var initialState: TransitionViewState
    let finalState: TransitionViewState
    var options: ShiftViewOptions
    
    lazy var duration = calculateDuration()
    
    var matchOriginalAlpha: CGFloat = 1
    let viewOriginalAlpha: CGFloat
    
    let coordinateSpace: CoordinateSpace
    
    init(toView: UIView,
         container: UIView,
         coordinateSpace: CoordinateSpace,
         options: ShiftViewOptions,
         match: UIView?) {
        self.view = toView
        self.options = options
        self.viewOriginalAlpha = toView.alpha
        let finalState = TransitionViewState(view: toView, container: container)
        self.initialState = match.map{ TransitionViewState(view: $0, container: container) } ?? finalState
        self.finalState = finalState
        self.coordinateSpace = coordinateSpace
        self.match = match
        self.matchOriginalAlpha = match?.alpha ?? 0
    }
    
    func takeSnapshot() {
        snapshot = view.snapshot(sizing: options.contentSizing)
        
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
    
    func addSnapshot() {
        guard let snapshot = snapshot else { return }
        
        switch coordinateSpace {
        case .global(let container):
            container.addSubview(snapshot)
        case .parent(let parent):
            parent.snapshot?.addSubview(snapshot)
        }
    }
    
    func applyModifers() {
        options.animations.apply(to: &initialState)
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
                self.snapshot?.backgroundColor = self.finalState.backgroundColor
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
        return 2
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

extension Array where Element == TransitionView {
    
    var maxDuration: TimeInterval {
        return self.map{ $0.duration }.max() ?? 0
    }
    
    var rootView: TransitionView? {
        return first
    }
}

final class SnapshotView: UIView {
    
    let content: UIView
    let sizing: ContentSizing
    
    init(content: UIView, sizing: ContentSizing) {
        self.content = content
        self.sizing = sizing
        super.init(frame: content.frame)
        addSubview(content)
        backgroundColor = content.backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard sizing == .stretch else { return }
        content.frame = bounds
    }
}

enum CoordinateSpace {
    case global(UIView)
    case parent(TransitionView)
}
