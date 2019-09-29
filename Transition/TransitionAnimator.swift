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
                 isAppearing: Bool = true,
                 completion: @escaping (Bool) -> Void,
                 extraAnimations: (() -> Void)? = nil) {
        let transitionContainer = buildTransitionContainer(in: container)
        let fromViewShapshot = addFromViewSnapshot(fromView: fromView, container: container)
        
        let views = flatten(view: toView, container: transitionContainer)
        findMatches(in: fromView, container: transitionContainer, result: views)
        views.forEach { $0.takeSnapshot(container: transitionContainer) }
        
        onSnapshotsAdded?()
        
        // All snapshots have been taken, so we can remove the `fromViewShapshot`
        // since there be anymore flashing, and the transition can begin.
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
    
    private func flatten(view: UIView,
                         container: UIView) -> [TransitionView] {
        var result = [TransitionView]()
        flatten(view: view, container: container, result: &result)
        return result
    }
    
    private func flatten(view: UIView,
                         container: UIView, result: inout [TransitionView]) {
        for subview in view.subviews.reversed() {
            flatten(view: subview, container: container, result: &result)
        }
        
        guard !view.isHidden else { return }
        
        result.append(TransitionView(toView: view, container: container))
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
        if let id = view.transition.id {
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
