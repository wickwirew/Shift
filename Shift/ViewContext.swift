//
//  TransitionView.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

/// Manages a view during the transition process.
/// It is aware of the view it is animating and any
/// matches it may have.
/// It will take all snapshot, manage adding the `view` to
/// the correct `superview` for the transition, and actually
/// apply all of the correct animations.
public final class ViewContext {
    /// Whether or not the view is the root view being transitioned.
    /// If view controllers are being transitioned this would be the
    /// view controller's `view` property.
    public let isRootView: Bool
    /// The view being animated.
    let view: UIView
    /// The match for the view if any.
    private var match: UIView?
    /// The snapshot of view view that the animations will be applied to.
    private var snapshot: Snapshot?
    /// The starting view state for the `snapshot`
    private var initialState: ViewState
    /// The final view state for the `snapshot`
    private var finalState: ViewState
    /// The superview for the `snapshot`
    private var superview: Superview
    /// The `match`'s original alpha.
    private var matchOriginalAlpha: CGFloat = 0
    /// The `view`'s original alpha.
    private let viewOriginalAlpha: CGFloat
    /// Whether or not to reverse the animations.
    private var reverseAnimations: Bool
    /// The minimum time for the duration calculation.
    private let baselineDuration: TimeInterval
    /// Any options for the view.
    /// These are a mutable copy of the the view's original options.
    private var options: ShiftViewOptions
    /// The animation duration.
    lazy var duration = calculateDuration()
    
    init(view: UIView,
         match: UIView?,
         superview: Superview,
         reverseAnimations: Bool,
         baselineDuration: TimeInterval,
         isRootView: Bool) {
        self.view = view
        self.match = match
        self.options = view.shift.copy()
        self.viewOriginalAlpha = view.alpha
        self.matchOriginalAlpha = match?.alpha ?? 0
        self.superview = superview
        self.reverseAnimations = reverseAnimations
        self.baselineDuration = baselineDuration
        self.isRootView = isRootView
        
        if let match = match {
            if reverseAnimations {
                self.finalState = ViewState(view: match, superview: superview)
                self.initialState = ViewState(view: view, superview: superview)
            } else {
                self.initialState = ViewState(view: match, superview: superview)
                self.finalState = ViewState(view: view, superview: superview)
            }
        } else {
            let finalState = ViewState(view: view, superview: superview)
            self.initialState = finalState
            self.finalState = finalState
        }
    }
    
    /// The identifier for the view.
    public var id: String? {
        return options.id
    }
    
    /// Any animations to apply to the view.
    public var animations: Animations {
        return options.animations
    }
    
    /// Takes the snapshot of the `view` and `match`.
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
                animation: .final
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

    /// Adds the `snapshot` to the defined `superview`
    func addSnapshot() {
        // if view is hidden then it will not have a value.
        guard let snapshot = snapshot else { return }
        
        switch superview {
        case .global(let container):
            container.addSubview(snapshot)
        case .parent(let parent):
            parent.snapshot?.addSubview(snapshot)
        }
    }
    
    /// Adjusts the `snapshot`s position in the view container.
    /// This cannot be done in `addSnapshot`, since not all views
    /// have been added yet. There is still a chance a view can
    /// be added on top.
    func adjustPosition() {
        guard let snapshot = snapshot else { return }
        
        switch options.position {
        case .auto:
            break // already in the right position
        case .front:
            snapshot.superview?.bringSubviewToFront(snapshot)
        case .back:
            snapshot.superview?.sendSubviewToBack(snapshot)
        }
    }
    
    /// Applies any animations to the view.
    func applyModifers(filter: Animations.Filter) {
        // Only unmatched view can have animations applied.
        guard match == nil else { return }
        
        if reverseAnimations {
            options.animations.apply(to: &finalState, filter: filter)
        } else {
            options.animations.apply(to: &initialState, filter: filter)
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
        // The max duration should be 0.375 seconds
        // The lowest should be 0.2 seconds
        // So there is an additional 0.175 seconds to add based off
        // how far the view is going to move or how much
        // it will change in size.
        let additionalDuration = 0.175
        
        let positionDistance = initialState.position.distance(to: finalState.position)
        let positionDuration = additionalDuration * TimeInterval(positionDistance.clamp(0, 500) / 500)
        
        return baselineDuration + positionDuration
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
