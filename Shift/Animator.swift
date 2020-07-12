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
    public var toViewControllerType: UIViewController.Type?
    public var fromViewControllerType: UIViewController.Type?
    public var defaultAnimation: DefaultShiftAnimation?
    
    public init(isPresenting: Bool = true,
                viewOrder: ViewOrder = .auto,
                baselineDuration: TimeInterval? = nil,
                toViewControllerType: UIViewController.Type? = nil,
                fromViewControllerType: UIViewController.Type? = nil,
                defaultAnimation: DefaultShiftAnimation? = nil) {
        self.isPresenting = isPresenting
        self.viewOrder = viewOrder
        self.baselineDuration = baselineDuration ?? 0.265
        self.toViewControllerType = toViewControllerType
        self.fromViewControllerType = fromViewControllerType
        self.defaultAnimation = defaultAnimation
    }
    
    /// How the `toView`'s and `fromView`'s will be ordered within
    /// the transition container.
    public enum ViewOrder {
        /// On presenting the `toView` will be on top,
        /// and on dismissal the `fromView` will be onTop
        case auto
        /// The `toView`s will be on top
        case toViewsOnTop
        /// The `fromView`s will be on top.
        case fromViewsOnTop
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
        
        options.defaultAnimation?.apply(to: views, options: options)
        
        applyAnimations(to: views, options: options)
        
        views.topViews.reversed().forEach { $0.takeSnapshot() }
        views.bottomViews.reversed().forEach { $0.takeSnapshot() }
        
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

    private func applyAnimations(to views: ShiftViews,
                                 options: Options) {
        let filter = Animations.Filter(
            mode: options.isPresenting ? .onAppear : .onDisappear,
            toViewControllerType: options.toViewControllerType,
            fromViewControllerType: options.fromViewControllerType
        )
        
        views.toViews.forEach{ $0.applyModifers(filter: filter) }
        views.fromViews.forEach{ $0.applyModifers(filter: filter) }
    }
    
    /// Builds the list of `views` used for the transition,
    /// and also assigns any matches that may exist.
    private func buildViews(fromView: UIView,
                            toView: UIView,
                            container: UIView,
                            options: Options) -> ShiftViews {
        let fromViews = deconstruct(
            view: fromView,
            container: container,
            reverseAnimations: true,
            baselineDuration: options.baselineDuration
        )
        
        let toViews = deconstruct(
            view: toView,
            container: container,
            reverseAnimations: false,
            baselineDuration: options.baselineDuration
        )
        
        findMatches(
            toViews: toViews,
            fromViews: fromViews,            
            container: container,
            isPresenting: options.isPresenting
        )
        
        return ShiftViews(
            fromViews: fromViews,
            toViews: toViews,
            order: options.viewOrder,
            isPresenting: options.isPresenting
        )
    }

    func findMatches(toViews: [ViewContext],
                     fromViews: [ViewContext],
                     container: UIView,
                     isPresenting: Bool) {
        /// The views that the matches will be assigned too.
        let sourceViews: [ViewContext]
        /// The views that are potential matches for the source views.
        /// Any view that is matched will be hidden in these views
        /// since they are matched in the source view.
        let otherViews: [ViewContext]
        
        // We want to always match against the view being transitioned too,
        // or the view being dismissed.
        if isPresenting {
            sourceViews = toViews
            otherViews = fromViews
        } else {
            sourceViews = fromViews
            otherViews = toViews
        }
        
        findMatches(
            for: sourceViews,
            in: otherViews,
            container: container
        )
    }
    
    func findMatches(for sourceViews: [ViewContext],
                     in otherViews: [ViewContext],
                     container: UIView) {
        // Get a lookup of views by their `shift.id`
        let otherViewsByIds = otherViews
            .filter{ $0.options.id != nil }
            .reduce(into: [String: ViewContext](), { $0[$1.options.id!] = $1 })

        // Loop through views, and looking for matches.
        for view in sourceViews {
            guard let id = view.options.id,
                let match = otherViewsByIds[id] else { continue }
            
            match.options.isHidden = true
            
            view.setMatch(to: match, container: container)
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
        
        if view.shift.requiresAnimation || parent == nil {
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
                baselineDuration: baselineDuration,
                isRootView: parent == nil
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


/// The collection of views that will be used for the transition.
/// It only contains the views that need to be animated. All others
/// are captured within the snapshots.
public final class ShiftViews: Collection {
    public typealias Index = Int
    public typealias Element = ViewContext
    
    /// The views being transitioned from.
    public let fromViews: [ViewContext]
    /// The views being transitioned too.
    public let toViews: [ViewContext]
    /// The how to order the `toViews` and `fromViews`
    private let order: Options.ViewOrder
    /// Whether or not the view is being presented.
    private let isPresenting: Bool
    
    init(fromViews: [ViewContext],
         toViews: [ViewContext],
         order: Options.ViewOrder,
         isPresenting: Bool) {
        self.fromViews = fromViews
        self.toViews = toViews
        self.order = order
        self.isPresenting = isPresenting
    }
    
    /// The source view is either the view being transitioned to,
    /// or the view being dismissed.
    /// This is the view that all matches reside in as well.
    public var sourceViewRoot: ViewContext? {
        return isPresenting ? toRootView : fromRootView
    }
    
    /// The view we are transitioning from.
    public var fromRootView: ViewContext? {
        return fromViews.first { $0.isRootView }
    }
    
    /// The view we are transitioning too.
    public var toRootView: ViewContext? {
        return toViews.first { $0.isRootView }
    }
    
    /// The views at the bottom of the container.
    /// These are below the `topViews`
    public var bottomViews: [ViewContext] {
        switch order {
        case .auto:
            return isPresenting ? fromViews : toViews
        case .fromViewsOnTop:
            return toViews
        case .toViewsOnTop:
            return fromViews
        }
    }
    
    /// The views at the top of the container.
    /// These are abolve the `bottomViews`
    public var topViews: [ViewContext] {
        switch order {
        case .auto:
            return isPresenting ? toViews : fromViews
        case .fromViewsOnTop:
            return fromViews
        case .toViewsOnTop:
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
}
