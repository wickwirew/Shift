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
    
    var views = [TransitionView]()
    
    var onSnapshotsAdded: Hook?
    
    let duration = 0.2
    
    func animate(fromView: UIView,
                 toView: UIView,
                 container: UIView,
                 isAppearing: Bool = true,
                 completion: @escaping (Bool) -> Void,
                 extraAnimations: (() -> Void)? = nil) {
        
        findMatches(fromView: fromView, toView: toView, container: container)
        takeSnapshots(container: container)
        
        onSnapshotsAdded?()
        
        views.forEach{ $0.performNonAnimatedChanges() }
        views.forEach{ $0.performCaAnimations() }
        views.forEach{ $0.performUiViewAnimations() }
        
        /// Get the longest duration
        let duration = views.map{ $0.duration }.max() ?? 0
        
        /// Animate the root view in at the longest duration
        let rootSnapshot = animateRootView(
            fromView: fromView,
            toView: toView,
            container: container,
            duration: duration,
            isAppearing: isAppearing
        )
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + duration,
            execute: {
                completion(true)
                self.views.forEach{ $0.finish() }
                rootSnapshot?.removeFromSuperview()
            }
        )
    }
    
    func findMatches(fromView: UIView, toView: UIView, container: UIView) {
        let fromViews = findViews(in: fromView)
        let toViews = findViews(in: toView)

        for (id, view) in fromViews {
            guard let match = toViews[id] else { continue }
            
            let value = TransitionView(
                fromView: view.0,
                toView: match.0,
                location: view.1,
                container: container
            )
            
            views.append(value)
        }
    }
    
    func takeSnapshots(container: UIView) {
        // sort views by their depth in the view tree so the
        // subviews are not included in the snapshot
        views.sorted(by: { $0.location > $1.location })
            .forEach{ $0.takeSnapshot(container: container) }
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
    
    /// Handles animating the root target view in.
    /// If it does not have any id then it should be faded in.
    private func animateRootView(fromView: UIView,
                                 toView: UIView,
                                 container: UIView,
                                 duration: TimeInterval,
                                 isAppearing: Bool) -> UIView? {
        let root = isAppearing ? toView : fromView
        let initialAlpha: CGFloat = isAppearing ? 0 : 1
        let targetAlpha: CGFloat = isAppearing ? 1 : 0
        
        let oldAlpha = root.alpha
        root.alpha = 1
        
        guard !views.contains(where: { $0.fromView == root }),
            let snapshot = root.snapshotView(afterScreenUpdates: true) else { return nil }

        snapshot.frame = root.frame
        
        root.alpha = oldAlpha
        
        container.insertSubview(snapshot, at: 0)
        snapshot.alpha = initialAlpha
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(.normal)
        
        UIView.animate(
            withDuration: duration,
            animations: { snapshot.alpha = targetAlpha }
        )
        
        CATransaction.commit()
        
        return snapshot
    }
}
