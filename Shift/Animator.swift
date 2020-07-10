//
//  TransitionAnimator.swift
//  ExpandoCell
//
//  Created by Wes Wickwire on 9/17/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

public struct Options {
    public var isPresenting: Bool
    public var viewOrder: ViewOrder
    public var baselineDuration: TimeInterval
    
    public init(isPresenting: Bool = true,
                viewOrder: ViewOrder = .sourceOnTop,
                baselineDuration: TimeInterval? = nil) {
        self.isPresenting = isPresenting
        self.viewOrder = viewOrder
        self.baselineDuration = baselineDuration ?? 0.2
    }
    
    public enum ViewOrder {
        case sourceOnTop
        case sourceOnBottom
    }
}

/// Performs all animations for the transition.
public final class Animator {
    public func animate(fromView: UIView,
                        toView: UIView,
                        container: UIView,
                        options: Options = Options(),
                        completion: @escaping (Bool) -> Void) {
        let transitionContainer = buildTransitionContainer(in: container, frame: toView.frame)
        let fromViewShapshot = addFromViewSnapshot(fromView: fromView, container: container)
        
        let views = buildViews(
            fromView: fromView,
            toView: toView,
            container: transitionContainer,
            options: options
        )
        
        views.forEach{ $0.applyModifers() }
        
        views.sourceViews.reversed().forEach { $0.takeSnapshot() }
        views.otherViews.reversed().forEach { $0.takeSnapshot() }
        
        views.forEach { $0.addSnapshot() }
        views.forEach { $0.adjustPosition() }
        
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

    private func buildViews(fromView: UIView,
                            toView: UIView,
                            container: UIView,
                            options: Options) -> Views {
        let sourceView: UIView
        let otherView: UIView
        
        if options.isPresenting {
            sourceView = toView
            otherView = fromView
        } else {
            sourceView = fromView
            otherView = toView
        }
        
        var otherViews = deconstruct(
            view: otherView,
            container: container,
            reverseAnimations: options.isPresenting,
            baselineDuration: options.baselineDuration
        )
        
        let sourceViews = deconstruct(
            view: sourceView,
            container: container,
            reverseAnimations: !options.isPresenting,
            baselineDuration: options.baselineDuration
        )
        
        findMatches(
            sourceViews: sourceViews,
            otherViews: &otherViews,
            container: container,
            isPresenting: options.isPresenting
        )
        
        return Views(
            otherViews: otherViews,
            sourceViews: sourceViews,
            order: options.viewOrder
        )
    }

    func findMatches(sourceViews: [ViewContext],
                     otherViews: inout [ViewContext],
                     container: UIView,
                     isPresenting: Bool) {
        let otherViewsByIds = otherViews
            .filter{ $0.options.id != nil }
            .reduce(into: [String: ViewContext](), { $0[$1.options.id!] = $1 })

        for view in sourceViews {
            guard let id = view.options.id,
                let match = otherViewsByIds[id] else { continue }
            
            match.options.isHidden = true
            
            view.setMatch(to: match, container: container)
            view.reverseAnimations = !isPresenting
        }
    }

    private func deconstruct(view: UIView,
                             container: UIView,
                             reverseAnimations: Bool,
                             baselineDuration: TimeInterval,
                             parent: ViewContext? = nil) -> [ViewContext] {
        guard !view.isHidden else { return [] }
        
        var views = [ViewContext]()
        var parent = parent
        
        if view.shift.requiresAnimation {
            let superView: Superview
            if let parent = parent, view.shift.superview != .container {
                superView = .parent(parent)
            } else {
                superView = .global(container)
            }
            
            let context = ViewContext(
                toView: view,
                superview: superView,
                reverseAnimations: reverseAnimations,
                baselineDuration: baselineDuration
            )
            
            views.append(context)
            parent = context
        }
        
        for subview in view.subviews {
            let subviews = deconstruct(
                view: subview,
                container: container,
                reverseAnimations: reverseAnimations,
                baselineDuration: baselineDuration,
                parent: parent
            )
            
            views.append(contentsOf: subviews)
        }
        
        return views
    }

    private func delay(_ duration: TimeInterval, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + duration,
            execute: action
        )
    }

    /// We want to build a new container for the transition, so all snapshots
    /// can be added to this while not affect the original `container`'s subview heirarchy
    private func buildTransitionContainer(in container: UIView, frame: CGRect) -> UIView {
        let newContainer = UIView()
        container.addSubview(newContainer)
        newContainer.frame = frame
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

public final class Views: Collection {
    
    public typealias Index = Int
    public typealias Element = ViewContext
    
    public let otherViews: [ViewContext]
    public let sourceViews: [ViewContext]
    
    private let order: Options.ViewOrder
    
    init(otherViews: [ViewContext],
         sourceViews: [ViewContext],
         order: Options.ViewOrder) {
        self.otherViews = otherViews
        self.sourceViews = sourceViews
        self.order = order
    }
    
    public var otherRootView: ViewContext? {
        return otherViews.first
    }
    
    public var sourceRootView: ViewContext? {
        return sourceViews.first
    }
    
    public var bottomViews: [ViewContext] {
        switch order {
        case .sourceOnBottom:
            return sourceViews
        case .sourceOnTop:
            return otherViews
        }
    }
    
    public var topViews: [ViewContext] {
        switch order {
        case .sourceOnBottom:
            return otherViews
        case .sourceOnTop:
            return sourceViews
        }
    }
    
    public var startIndex: Int {
        return bottomViews.startIndex
    }
    
    public var maxDuration: TimeInterval {
        return map{ $0.duration }.max() ?? 0
    }
       
    public var endIndex: Int {
        return bottomViews.endIndex + topViews.endIndex
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    public subscript(position: Int) -> ViewContext {
        if position < bottomViews.endIndex {
            return bottomViews[position]
        } else {
            return topViews[position - bottomViews.endIndex]
        }
    }
}
