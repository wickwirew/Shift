//
//  TransitionAnimator.swift
//  ExpandoCell
//
//  Created by Wes Wickwire on 9/17/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

/// Performs all animations for the transition.
public final class Animator {
    /// Whether or not a view is being presented or dismissed.
    private let isPresenting: Bool
    /// How to order the views within the transition container.
    private let viewOrder: ViewOrder
    /// The minimum time for the duration caclulations.
    private let baselineDuration: TimeInterval
    /// The default animation to be run.
    private let defaultAnimation: DefaultShiftAnimation?
    /// The view we are transitioning from.
    private let fromView: UIView
    /// The view we are transitioning too.
    private let toView: UIView
    /// The container in which the transition is happening.
    private let container: UIView
    /// The view controller's type that is being transitioned from.
    private let fromViewControllerType: UIViewController.Type?
    /// The view controller's type that is being transitioned too.
    private let toViewControllerType: UIViewController.Type?
    
    public init(fromView: UIView,
                toView: UIView,
                container: UIView,
                isPresenting: Bool,
                viewOrder: ViewOrder = .auto,
                baselineDuration: TimeInterval? = nil,
                defaultAnimation: DefaultShiftAnimation? = nil,
                fromViewControllerType: UIViewController.Type? = nil,
                toViewControllerType: UIViewController.Type? = nil) {
        self.fromView = fromView
        self.toView = toView
        self.container = container
        self.isPresenting = isPresenting
        self.viewOrder = viewOrder
        self.baselineDuration = baselineDuration ?? 0.265
        self.defaultAnimation = defaultAnimation
        self.fromViewControllerType = fromViewControllerType
        self.toViewControllerType = toViewControllerType
    }
    
    public convenience init(fromView fromViewController: UIViewController,
                            toView toViewController: UIViewController,
                            container: UIView,
                            isPresenting: Bool) {
        // For presenting we want to use the toViewControllers options,
        // on dismissal we want the fromViewController since it is being dismissed.
        let sourceViewController = isPresenting ? toViewController : fromViewController
        
        self.init(fromView: fromViewController.view,
            toView: toViewController.view,
            container: container,
            isPresenting: isPresenting,
            viewOrder: sourceViewController.shift.viewOrder,
            baselineDuration: sourceViewController.shift.baselineDuration,
            defaultAnimation: sourceViewController.shift.defaultAnimation,
            fromViewControllerType: type(of: fromViewController),
            toViewControllerType: type(of: toViewController)
        )
    }
    
    /// The view being presented or dismissed.
    private var sourceView: UIView {
        return isPresenting ? toView : fromView
    }
    
    /// The other view than the `sourceView`
    private var nonSourceView: UIView {
        return isPresenting ? fromView : toView
    }
    
    /// Perform the transition animation.
    /// - Parameter completion: A closure to be called on completion.
    public func animate(completion: @escaping (Bool) -> Void) {
        let transitionContainer = buildTransitionContainer(in: container, frame: toView.frame)
        let fromViewShapshot = addFromViewSnapshot(fromView: fromView, container: container)
        
        let views = buildViews()
        
        defaultAnimation?.apply(to: views, isPresenting: isPresenting)
        
        applyAnimations(to: views)
        
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

    private func applyAnimations(to views: ShiftViews) {
        let filter = Animations.Filter(
            mode: isPresenting ? .onAppear : .onDisappear,
            toViewControllerType: toViewControllerType,
            fromViewControllerType: fromViewControllerType
        )
        
        views.toViews.forEach{ $0.applyModifers(filter: filter) }
        views.fromViews.forEach{ $0.applyModifers(filter: filter) }
    }
    
    /// Builds the list of `views` used for the transition,
    /// and also assigns any matches that may exist.
    private func buildViews() -> ShiftViews {
        // Bit of a logic shift here. Normally we can think about things
        // in the context of "to" and "from" views. However we need to make the matches
        // in the "source" view. e.g. the view being presented or dismissed.
        
        let potential = potentialMatches(of: nonSourceView)
        
        let (sourceViews, matches) = animatedViews(
            of: sourceView,
            reverseAnimations: !isPresenting,
            potentialMatches: potential,
            ignoreViews: []
        )
        
        let (nonSourceViews, _) = animatedViews(
            of: nonSourceView,
            reverseAnimations: isPresenting,
            potentialMatches: [:],
            ignoreViews: matches
        )
        
        return ShiftViews(
            fromViews: isPresenting ? nonSourceViews : sourceViews,
            toViews: isPresenting ? sourceViews : nonSourceViews,
            order: viewOrder,
            isPresenting: isPresenting
        )
    }
    
    /// Builds up a list of views that need to be animated in the transition.
    private func animatedViews(of view: UIView,
                               reverseAnimations: Bool,
                               potentialMatches: [String: UIView],
                               ignoreViews: Set<String>,
                               parent: ViewContext? = nil) -> ([ViewContext], Set<String>) {
        var views = [ViewContext]()
        var matches = Set<String>()
        
        animatedViews(
            of: view,
            reverseAnimations: reverseAnimations,
            potentialMatches: potentialMatches,
            ignoreViews: ignoreViews,
            parent: parent,
            views: &views,
            matches: &matches
        )
        
        return (views, matches)
    }
    
    /// Builds up a list of views that need to be animated in the transition.
    private func animatedViews(of view: UIView,
                               reverseAnimations: Bool,
                               potentialMatches: [String: UIView],
                               ignoreViews: Set<String>,
                               parent: ViewContext?,
                               views: inout [ViewContext],
                               matches: inout Set<String>) {
        guard !view.isHidden else { return}
        var parent = parent
        
        if let id = view.shift.id, ignoreViews.contains(id) {
            // View is listed in the ignore views so ignore.
            // It was already matched so it exists in the other view.
            return
        }
        
        if let id = view.shift.id, let match = potentialMatches[id] {
            let context = ViewContext(
                view: view,
                match: match,
                superview: .global(container),
                reverseAnimations: reverseAnimations,
                baselineDuration: baselineDuration,
                isRootView: parent == nil
            )
            
            matches.insert(id)
            views.append(context)
            parent = context
        } else if view.shift.requiresAnimation || parent == nil {
            let superView: Superview
            if let parent = parent, view.shift.superview != .container {
                superView = .parent(parent)
            } else {
                superView = .global(container)
            }
            
            let context = ViewContext(
                view: view,
                match: nil,
                superview: superView,
                reverseAnimations: reverseAnimations,
                baselineDuration: baselineDuration,
                isRootView: parent == nil
            )
            
            views.append(context)
            parent = context
        }
        
        for subview in view.subviews {
            animatedViews(
                of: subview,
                reverseAnimations: reverseAnimations,
                potentialMatches: potentialMatches,
                ignoreViews: ignoreViews,
                parent: parent,
                views: &views,
                matches: &matches
            )
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
    
    /// Builds up a dictionary of views that have an `id` set.
    func potentialMatches(of view: UIView) -> [String: UIView] {
        var result = [String: UIView]()
        potentialMatches(of: view, result: &result)
        return result
    }
    
    /// Builds up a dictionary of views that have an `id` set.
    private func potentialMatches(of view: UIView, result: inout [String: UIView]) {
        if let id = view.shift.id {
            result[id] = view
        }
        
        for subview in view.subviews {
            potentialMatches(of: subview, result: &result)
        }
    }
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
    private let order: ViewOrder
    /// Whether or not the view is being presented.
    private let isPresenting: Bool
    
    init(fromViews: [ViewContext],
         toViews: [ViewContext],
         order: ViewOrder,
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
