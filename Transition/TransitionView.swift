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
    
    func caAnimations() {
        guard let snapshot = snapshot else { return }

        let from = initialState
        let to = finalState
        
        if from.cornerRadius != to.cornerRadius {
            snapshot.layer.addAnimation(for: .cornerRadius, from: from.cornerRadius, to: to.cornerRadius, finalState: finalState)
            snapshot.layer.cornerRadius = to.cornerRadius
        }
        
        if from.anchorPoint != to.anchorPoint {
            snapshot.layer.addAnimation(for: .anchorPoint, from: from.anchorPoint, to: to.anchorPoint, finalState: finalState)
            snapshot.layer.anchorPoint = to.anchorPoint
        }
        
        if from.zPosition != to.zPosition {
            snapshot.layer.addAnimation(for: .zPosition, from: from.zPosition, to: to.zPosition, finalState: finalState)
            snapshot.layer.zPosition = to.zPosition
        }
        
        if from.opacity != to.opacity {
            snapshot.layer.addAnimation(for: .opacity, from: from.opacity, to: to.opacity, finalState: finalState)
            snapshot.layer.opacity = to.opacity
        }
        
        if from.isOpaque != to.isOpaque {
            snapshot.layer.addAnimation(for: .isOpaque, from: from.isOpaque, to: to.isOpaque, finalState: finalState)
            snapshot.layer.isOpaque = to.isOpaque
        }
        
        if from.borderColor != to.borderColor {
            snapshot.layer.addAnimation(for: .borderColor, from: from.borderColor, to: to.borderColor, finalState: finalState)
            snapshot.layer.borderColor = to.borderColor
        }
        
        if from.borderWidth != to.borderWidth {
            snapshot.layer.addAnimation(for: .borderWidth, from: from.borderWidth, to: to.borderWidth, finalState: finalState)
            snapshot.layer.borderWidth = to.borderWidth
        }
        
        if from.contentsRect != to.contentsRect {
            snapshot.layer.addAnimation(for: .contentsRect, from: from.contentsRect, to: to.contentsRect, finalState: finalState)
            snapshot.layer.contentsRect = to.contentsRect
        }
        
        if from.contentsScale != to.contentsScale {
            snapshot.layer.addAnimation(for: .contentsScale, from: from.contentsScale, to: to.contentsScale, finalState: finalState)
            snapshot.layer.contentsScale = to.contentsScale
        }
        
        if from.shadowColor != to.shadowColor {
            snapshot.layer.addAnimation(for: .shadowColor, from: from.shadowColor, to: to.shadowColor, finalState: finalState)
            snapshot.layer.shadowColor = to.shadowColor
        }

        if from.shadowOffset != to.shadowOffset {
            snapshot.layer.addAnimation(for: .shadowOffset, from: from.shadowOffset, to: to.shadowOffset, finalState: finalState)
            snapshot.layer.shadowOffset = to.shadowOffset
        }

        if from.shadowRadius != to.shadowRadius {
            snapshot.layer.addAnimation(for: .shadowRadius, from: from.shadowRadius, to: to.shadowRadius, finalState: finalState)
            snapshot.layer.shadowRadius = to.shadowRadius
        }
        
        if from.shadowOpacity != to.shadowOpacity {
            snapshot.layer.addAnimation(for: .shadowOpacity, from: from.shadowOpacity, to: to.shadowOpacity, finalState: finalState)
            snapshot.layer.shadowOpacity = to.shadowOpacity
        }
        
        if from.shadowPath != to.shadowPath {
            let fromPath = from.shadowPath ?? UIBezierPath(rect: from.bounds).cgPath
            let toPath = to.shadowPath ?? UIBezierPath(rect: to.bounds).cgPath
            snapshot.layer.addAnimation(for: .shadowPath, from: fromPath, to: toPath, finalState: finalState)
            snapshot.layer.shadowPath = to.shadowPath
        }
        
        if from.transform != to.transform {
            snapshot.layer.addAnimation(for: .transform, from: from.transform, to: to.transform, finalState: finalState)
            snapshot.layer.transform = to.transform
        }
    }
    
    func uiViewAnimations() {
        guard let snapshot = snapshot else { return }
        
        snapshot.layer.position = finalState.position
        snapshot.alpha = finalState.alpha
        snapshot.layer.bounds = finalState.bounds
        snapshot.layer.zPosition = finalState.zPosition
    }
    
    func finish() {
        snapshot?.removeFromSuperview()
        fromView?.alpha = initialState.alpha
        toView?.alpha = finalState.alpha
    }
}
