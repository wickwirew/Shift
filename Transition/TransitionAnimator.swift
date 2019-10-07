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
        views.forEach { $0.takeSnapshot() }
        views.forEach { $0.insertSnapshot() }
        
        applyDefaultTransition(views: views)
        
        onSnapshotsAdded?()
        
        // All snapshots have been taken, so we can remove the `fromViewShapshot`
        // since there wont be anymore flashing, and the transition can begin.
        fromViewShapshot.removeFromSuperview()
        
        views.forEach{ $0.applyModifiers() }
        
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
            guard let id = transitionView.options.id,
                let match = views[id] else { continue }

            transitionView.setMatch(view: match.0, container: container)
        }
    }
    
    private func deconstruct(view: UIView,
                             container: UIView) -> [TransitionView] {
        var roots = [TransitionView]()
        
        let root = TransitionView(
            toView: view,
            container: container,
            coordinateSpace: .global(container),
            options: view.shift
        )
        
        deconstruct(view: view, container: container, parent: root, roots: &roots)
        
        roots.append(root)
        
        return roots
    }
    
    private func deconstruct(view: UIView,
                             container: UIView,
                             parent: TransitionView,
                             roots: inout [TransitionView]) {
        guard !view.isHidden else { return }
        
        let options = view.shift
        let hasMatch = options.id?.isEmpty == false
        let viewNeedsAnimating = hasMatch || !options.animations.isEmpty
        
        let result: TransitionView? = !viewNeedsAnimating ? nil : TransitionView(
            toView: view,
            container: container,
            coordinateSpace: hasMatch ? .global(container) : .parent(parent),
            options: options
        )
        
        // Make sure to visit the subviews in reverse order since we want
        // to visit the "Top Views" first.
        for subview in view.subviews.reversed() {
            deconstruct(
                view: subview,
                container: container,
                parent: result != nil ? result! : parent,
                roots: &roots
            )
        }
        
        result.map { roots.append($0) }
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
    
    /// TODO: add ability to more default animations
    private func applyDefaultTransition(views: [TransitionView]) {
        views.rootView?.options.animations = [.fade]
    }
}
