//
//  TransitionAnimator.swift
//  ExpandoCell
//
//  Created by Wes Wickwire on 9/17/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

public typealias Middleware = (Views) -> Void

public struct Options {
    
    public var isPresenting: Bool
    public var viewOrder: ViewOrder
    
    public init(isPresenting: Bool = true,
                viewOrder: ViewOrder = .sourceOnTop) {
        self.isPresenting = isPresenting
        self.viewOrder = viewOrder
    }
    
    public enum ViewOrder {
        case sourceOnTop
        case sourceOnBottom
    }
}

public func animate(fromView: UIView,
                    toView: UIView,
                    container: UIView,
                    options: Options = Options(),
                    middleware: [Middleware] = [],
                    completion: @escaping (Bool) -> Void,
                    extraAnimations: (() -> Void)? = nil) {
    let transitionContainer = buildTransitionContainer(in: container)
    let fromViewShapshot = addFromViewSnapshot(fromView: fromView, container: container)
    
    let views = buildViews(
        fromView: fromView,
        toView: toView,
        container: container,
        options: options
    )
    
    middleware.forEach{ $0(views) }
    
    views.forEach{ $0.applyModifers() }
    
    /*
     
     */
    
    if options.isPresenting {
        views.toViews.reversed().forEach { $0.takeSnapshot() }
        views.fromViews.reversed().forEach { $0.takeSnapshot() }
    } else {
        views.fromViews.reversed().forEach { $0.takeSnapshot() }
        views.toViews.reversed().forEach { $0.takeSnapshot() }
    }
    
    views.forEach { $0.addSnapshot() }
    
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
    var fromViews = deconstruct(
        view: fromView,
        container: container,
        reverseAnimations: true
    )
    
    var toViews = deconstruct(
        view: toView,
        container: container,
        reverseAnimations: false
    )
    
    findMatches(
        toViews: &toViews,
        fromViews: &fromViews,
        container: container,
        isPresenting: options.isPresenting
    )
    
    /*
     Matches should always be against source views
        - Need to reverse the animation on dimissing.
        -
     */
    
    let order: Views.Order
    switch options.viewOrder {
    case .sourceOnTop:
        order = options.isPresenting ? .fromViewsFirst : .toViewsFirst
    case .sourceOnBottom:
        order = options.isPresenting ? .toViewsFirst : .fromViewsFirst
    }
    
    return Views(
        fromViews: fromViews,
        toViews: toViews,
        order: order
    )
}

func findMatches(toViews: inout [ViewContext],
                 fromViews: inout [ViewContext],
                 container: UIView,
                 isPresenting: Bool) {
    // The view to find the matches in will always be the source view.
    let sourceViews = isPresenting ? toViews : fromViews

    // The view to search through for matches
    let targetViews = isPresenting ? fromViews : toViews

    let targetViewsByIds = targetViews
        .filter{ $0.options.id != nil }
        .reduce(into: [String: ViewContext](), { $0[$1.options.id!] = $1 })

    for view in sourceViews {
        guard let id = view.options.id,
            let match = targetViewsByIds[id] else { continue }
        
        match.discard = true
        
        view.setMatch(to: match, container: container)
        view.reverseAnimations = !isPresenting
    }

    if isPresenting {
        fromViews = targetViews.filter{ !$0.discard }
    } else {
        toViews = targetViews.filter{ !$0.discard }
    }
}

private func findAndRemoveMatches(from views: inout [ViewContext],
                                  against: inout [ViewContext],
                                  container: UIView) {
    var indexesToRemove = [Int]()
    
    let viewsById: [String: (offset: Int, element: ViewContext)] = against
        .enumerated()
        .filter{ $0.element.options.id != nil }
        .reduce(into: [:], { $0[$1.element.options.id!] = $1 })
    
    for (i, view) in views.enumerated() {
        guard let id = view.options.id,
            let match = viewsById[id] else { continue }
        
        view.setMatch(to: match.element, container: container)
        
        indexesToRemove.append(match.offset)
    }
    
    indexesToRemove
        .reversed()
        .forEach{ against.remove(at: $0) }
}

private func deconstruct(view: UIView,
                         container: UIView,
                         reverseAnimations: Bool,
                         parent: ViewContext? = nil) -> [ViewContext] {
    guard !view.isHidden else { return [] }
    
    var views = [ViewContext]()
    var parent = parent
    
    let viewNeedsAnimating = view.shift.id != nil
        || !view.shift.animations.isEmpty
        || parent == nil
        || view.shift.superview == .container
    
    if viewNeedsAnimating {
        let superView: Superview
        if let parent = parent, view.shift.superview != .container {
            superView = .parent(parent)
        } else {
            superView = .global(container)
        }
        
        let context = ViewContext(
            toView: view,
            superview: superView,
            reverseAnimations: reverseAnimations
        )
        
        views.append(context)
        parent = context
    }
    
    for subview in view.subviews {
        let subviews = deconstruct(
            view: subview,
            container: container,
            reverseAnimations: reverseAnimations,
            parent: parent
        )
        
        views.append(contentsOf: subviews)
    }
    
    return views
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

public final class Views: Collection {
    
    public typealias Index = Int
    public typealias Element = ViewContext
    
    public let fromViews: [ViewContext]
    public let toViews: [ViewContext]
    
    private let order: Order
    
    init(fromViews: [ViewContext],
         toViews: [ViewContext],
         order: Order) {
        self.fromViews = fromViews
        self.toViews = toViews
        self.order = order
    }
    
    public var fromRootView: ViewContext? {
        return fromViews.first
    }
    
    public var toRootView: ViewContext? {
        return toViews.first
    }
    
    public var bottomRootView: ViewContext? {
        return bottomViews.first
    }
    
    public var topRootView: ViewContext? {
        return topViews.first
    }
    
    public var bottomViews: [ViewContext] {
        switch order {
        case .toViewsFirst:
            return toViews
        case .fromViewsFirst:
            return fromViews
        }
    }
    
    public var topViews: [ViewContext] {
        switch order {
        case .toViewsFirst:
            return fromViews
        case .fromViewsFirst:
            return toViews
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
    
    enum Order {
        case toViewsFirst
        case fromViewsFirst
    }
}
