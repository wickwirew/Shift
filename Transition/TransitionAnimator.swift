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
        
        let views = deconstruct(view: toView, container: transitionContainer)
        findMatches(in: fromView, container: transitionContainer, result: views)
        views.forEach { $0.takeSnapshot(container: transitionContainer) }
        
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
    
    private func findMatches(in view: UIView,
                             container: UIView,
                             result: [TransitionView]) {
        let views = findViews(in: view)
        
        for transitionView in result {
            guard let id = transitionView.id,
                let match = views[id] else { continue }

            transitionView.setMatch(view: match.0, container: container)
        }
    }
    
    /// Desconstructs the view tree into a new list of treess
    private func deconstruct(view: UIView,
                             container: UIView) -> [TransitionView] {
        var roots = [TransitionView]()
        if let originalRoot = deconstruct(view: view, container: container, roots: &roots) {
            roots.append(originalRoot)
        }
        return roots
    }
    
    /// Does a post-order traversal over the view tree, and builds up a list
    /// of new sub trees (`roots`).
    ///
    /// Each root node must meet one of the following conditions:
    ///     A. The root view in the original tree
    ///     B. Has a `transition.id` set. This is important because these smaller
    ///        trees need to be added to the transition container, not to its
    ///        original parent's snapshot. So they can have their position animated
    ///        to it's new position and not be affected by its parents frame.
    private func deconstruct(view: UIView,
                             container: UIView,
                             roots: inout [TransitionView]) -> TransitionView? {
        guard !view.isHidden else { return nil }
        
        var subviews = [TransitionView]()
        
        // Make sure to visit the subviews in reverse order since we want
        // to visit the "Top Views" first.
        for subview in view.subviews.reversed() {
            guard let sv = deconstruct(view: subview, container: container, roots: &roots) else { continue }
            subviews.append(sv)
        }
        
        let result = TransitionView(
            toView: view,
            subviews: subviews,
            container: container,
            options: view.shift
        )
        
        // If the `shift.id` is set then it should be added to the list of roots.
        guard view.shift.id == nil else {
            roots.append(result)
            return nil
        }
        
        return result
    }
    
    private func findViews(in view: UIView) -> [String: (UIView, ViewLocation)] {
        var views = [String: (UIView, ViewLocation)]()
        findViews(in: view, depth: 0, index: 0, views: &views)
        return views
    }
    
    private func findViews(in view: UIView,
                           depth: Int,
                           index: Int,
                           views: inout [String: (UIView, ViewLocation)]) {
        if let id = view.shift.id {
            views[id] = (view, ViewLocation(depth: depth, index: index))
        }
        
        for (i, subview) in view.subviews.enumerated() {
            findViews(in: subview, depth: depth + 1, index: i, views: &views)
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
}
