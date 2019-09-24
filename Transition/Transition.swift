//
//  AnimationContext.swift
//  ExpandoCell
//
//  Created by Wes Wickwire on 9/17/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

final class Transition {
    
    typealias Hook = () -> Void
    
    var views = [TransitionView]()
    
    var onSnapshotsAdded: Hook?
    
    func animate(fromView: UIView,
                 toView: UIView,
                 container: UIView,
                 completion: @escaping (Bool) -> Void,
                 extraAnimations: (() -> Void)? = nil) {
        
        preprocess(fromView: fromView, toView: toView, container: container)
        takeSnapshots(container: container)
        
        onSnapshotsAdded?()
        
        let duration = 0.2
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        CATransaction.setCompletionBlock({
            completion(true)
            self.views.forEach{ $0.finish() }
        })
        
        views.forEach{ $0.caAnimations() }
        
        UIView.animate(
            withDuration: duration,
            animations: {
                self.views.forEach{ $0.uiViewAnimations() }
                extraAnimations?()
            }
        )

        CATransaction.commit()
    }
    
    func preprocess(fromView: UIView, toView: UIView, container: UIView) {
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
    
    private func findViews(in view: UIView, depth: Int, index: Int, views: inout [String: (UIView, ViewLocation)]) {
        if let id = view.transition.id {
            views[id] = (view, ViewLocation(depth: depth, index: index))
        }
        
        for (i, subview) in view.subviews.enumerated() {
            findViews(in: subview, depth: depth + 1, index: i, views: &views)
        }
    }
}
