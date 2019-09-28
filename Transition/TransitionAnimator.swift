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
        
        var views = flatten(view: toView, container: container)
        
        findMatches(in: fromView, container: container, result: &views)
        
        views.forEach { $0.takeSnapshot(container: container) }

        onSnapshotsAdded?()
        
        views.forEach{ $0.performNonAnimatedChanges() }
        views.forEach{ $0.performCaAnimations() }
        views.forEach{ $0.performUiViewAnimations() }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + views.maxDuration,
            execute: {
                completion(true)
                views.forEach{ $0.finish() }
            }
        )
    }
    
    private func findMatches(in view: UIView,
                             container: UIView,
                             result: inout [TransitionView]) {
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
}
