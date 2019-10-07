//
//  TransitionAnimator.swift
//  ExpandoCell
//
//  Created by Wes Wickwire on 9/17/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

final class TransitionAnimator {
    
    typealias Hook = () -> Void
    
    var onSnapshotsAdded: Hook?
    
    func animate(fromView: UIView,
                 toView: UIView,
                 container: UIView,
                 completion: @escaping (Bool) -> Void,
                 extraAnimations: (() -> Void)? = nil) {
        let transitionContainer = buildTransitionContainer(in: container)
        let fromViewShapshot = addFromViewSnapshot(fromView: fromView, container: container)
        
        let views = deconstruct(
            view: toView,
            container: transitionContainer,
            potentialMatches: findPotentialMatches(in: fromView)
        )
        
        applyDefaultTransition(views: views)
        
        views.forEach{ $0.applyModifers() }
        
        views.reversed().forEach { $0.takeSnapshot() }
        views.forEach { $0.addSnapshot() }
        
        onSnapshotsAdded?()
        
        // All snapshots have been taken, so we can remove the `fromViewShapshot`
        // since there wont be anymore flashing, and the transition can begin.
        fromViewShapshot.removeFromSuperview()
        
        views.forEach{ $0.performNonAnimatedChanges() }
        views.forEach{ $0.performCaAnimations() }
        views.forEach{ $0.performUiViewAnimations() }
        
        delay(views.maxDuration) {
            completion(true)
            views.forEach{ $0.finish() }
            transitionContainer.removeFromSuperview()
        }
    }
    
    private func deconstruct(view: UIView,
                             container: UIView,
                             potentialMatches: [String: UIView]) -> [TransitionView] {
        var roots = [TransitionView]()
        
        let root = TransitionView(
            toView: view,
            container: container,
            coordinateSpace: .global(container),
            options: view.shift,
            match: nil
        )
        
        roots.append(root)
        
        deconstruct(
            view: view,
            container: container,
            parent: root,
            roots: &roots,
            potentialMatches: potentialMatches
        )
        
        return roots
    }
    
    private func deconstruct(view: UIView,
                             container: UIView,
                             parent: TransitionView,
                             roots: inout [TransitionView],
                             potentialMatches: [String: UIView]) {
        guard !view.isHidden else { return }
        
        let options = view.shift
        let match = potentialMatches[options.id ?? ""]
        let hasMatch = match != nil
        let viewNeedsAnimating = match != nil || !options.animations.isEmpty
        
        let result: TransitionView? = !viewNeedsAnimating ? nil : TransitionView(
            toView: view,
            container: container,
            coordinateSpace: hasMatch ? .global(container) : .parent(parent),
            options: options,
            match: match
        )
        
        result.map { roots.append($0) }
        
        // Make sure to visit the subviews in reverse order since we want
        // to visit the "Top Views" first.
        for subview in view.subviews {
            deconstruct(
                view: subview,
                container: container,
                parent: result != nil ? result! : parent,
                roots: &roots,
                potentialMatches: potentialMatches
            )
        }
    }
    
    private func findPotentialMatches(in view: UIView) -> [String: UIView] {
        var views = [String: UIView]()
        findPotentialMatches(in: view, views: &views)
        return views
    }
    
    private func findPotentialMatches(in view: UIView,
                                      views: inout [String: UIView]) {
        if let id = view.shift.id {
            views[id] = view
        }
        
        for subview in view.subviews {
            findPotentialMatches(in: subview, views: &views)
        }
    }
    
    private func delay(_ duration: TimeInterval, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + duration,
            execute: action
        )
    }
    
    /// We want to build a new container for the transition, so all snapshots
    /// can be added to this while not affect the original `container`'s subview heirarchy
    private func buildTransitionContainer(in container: UIView) -> UIView {
        let newContainer = UIView()
        container.addSubview(newContainer)
        newContainer.frame = container.bounds
        return newContainer
    }
    
    /// We snapshot the `fromView`'s subviews and add them to the container.
    /// The alphas of the subviews are changed heavily which can result in some flashing.
    /// Adding the snapshot on top hides all of that.
    private func addFromViewSnapshot(fromView: UIView, container: UIView) -> UIView {
        let fromViewShapshot = fromView.snapshotView(afterScreenUpdates: false) ?? UIView()
        container.addSubview(fromViewShapshot)
        fromViewShapshot.frame = fromView.frame
        return fromViewShapshot
    }
    
    /// TODO: add ability to more default animations
    private func applyDefaultTransition(views: [TransitionView]) {
        views.rootView?.options.animations = [.fade]
    }
}
