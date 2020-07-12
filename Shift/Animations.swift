//
//  Animation.swift
//  Transition
//
//  Created by Wes Wickwire on 10/3/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

/// Additional animations that can be added to the view
/// during the transition.
public class Animations {
    /// A condition to optionally apply an animation based on
    /// an input filter.
    public struct Condition {
        public let predicate: (Filter) -> Bool
        
        public init(_ predicate: @escaping (Filter) -> Bool) {
            self.predicate = predicate
        }
        
        /// When the view is appearing
        public static var onAppear: Condition {
            return Condition { $0.isAppear }
        }
        
        /// When the view is disappearing
        public static var onDisappear: Condition {
            return Condition { $0.isDisappear }
        }
        
        /// Filter based on a custom `predicate`
        public static func filter(_ predicate: @escaping (Filter) -> Bool) -> Condition {
            return Condition(predicate)
        }
    }
    
    /// An animation to be applied to a view.
    struct Animation {
        /// The condition on whether or not to apply the animation
        let condition: Condition?
        /// Applies the animation to the view.
        let apply: (inout ViewState) -> Void
    }
    
    /// The aggregated list of animations to apply
    private var animations: [Animation]
    
    init(animations: [Animation] = []) {
        self.animations = animations
    }
    
    /// Whether or not there are any animations.
    var isEmpty: Bool {
        return animations.isEmpty
    }
    
    /// Fades the view.
    @discardableResult
    public func fade(_ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.alpha = 0
        })
        return self
    }
    
    /// Scales the view by the `value`
    @discardableResult
    public func scale(_ value: CGFloat, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.transform = CATransform3DScale(viewState.transform, value, value, value)
        })
        return self
    }
    
    /// Moves the view from the destination position.
    /// - Parameters:
    ///   - direction: The direction and value to move.
    @discardableResult
    public func move(_ direction: Direction, _ condition: Condition? = nil) -> Animations {
        switch direction {
        case .up(let value):
            return move(x: 0, y: value, condition)
        case .down(let value):
            return move(x: 0, y: -value, condition)
        case .left(let value):
            return move(x: value, y: 0, condition)
        case .right(let value):
            return move(x: -value, y: 0, condition)
        }
    }
    
    /// Moves the view from the destination position.
    /// - Parameters:
    ///   - x: The delta for the x axis
    ///   - y: The delta for the y axis
    @discardableResult
    public func move(x: CGFloat, y: CGFloat, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.position.x += x
            viewState.position.y += y
        })
        return self
    }
    
    /// Sets the `bounds` to the intended `value`.
    @discardableResult
    public func bounds(_ value: CGRect, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.bounds = value
        })
        return self
    }

    /// Sets the `alpha` to the intended `value`.
    @discardableResult
    public func alpha(_ value: CGFloat, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.alpha = value
        })
        return self
    }

    /// Sets the `cornerRadius` to the intended `value`.
    @discardableResult
    public func cornerRadius(_ value: CGFloat, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.cornerRadius = value
        })
        return self
    }

    /// Sets the `anchorPoint` to the intended `value`.
    @discardableResult
    public func anchorPoint(_ value: CGPoint, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.anchorPoint = value
        })
        return self
    }

    /// Sets the `zPosition` to the intended `value`.
    @discardableResult
    public func zPosition(_ value: CGFloat, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.zPosition = value
        })
        return self
    }

    /// Sets the `opacity` to the intended `value`.
    @discardableResult
    public func opacity(_ value: Float, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.opacity = value
        })
        return self
    }

    /// Sets the `isOpaque` to the intended `value`.
    @discardableResult
    public func isOpaque(_ value: Bool, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.isOpaque = value
        })
        return self
    }

    /// Sets the `masksToBounds` to the intended `value`.
    @discardableResult
    public func masksToBounds(_ value: Bool, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.masksToBounds = value
        })
        return self
    }

    /// Sets the `borderColor` to the intended `value`.
    @discardableResult
    public func borderColor(_ value: CGColor?, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.borderColor = value
        })
        return self
    }

    /// Sets the `borderWidth` to the intended `value`.
    @discardableResult
    public func borderWidth(_ value: CGFloat, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.borderWidth = value
        })
        return self
    }

    /// Sets the `contentsRect` to the intended `value`.
    @discardableResult
    public func contentsRect(_ value: CGRect, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.contentsRect = value
        })
        return self
    }

    /// Sets the `contentsScale` to the intended `value`.
    @discardableResult
    public func contentsScale(_ value: CGFloat, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.contentsScale = value
        })
        return self
    }

    /// Sets the `shadowColor` to the intended `value`.
    @discardableResult
    public func shadowColor(_ value: CGColor?, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.shadowColor = value
        })
        return self
    }

    /// Sets the `shadowOffset` to the intended `value`.
    @discardableResult
    public func shadowOffset(_ value: CGSize, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.shadowOffset = value
        })
        return self
    }

    /// Sets the `shadowRadius` to the intended `value`.
    @discardableResult
    public func shadowRadius(_ value: CGFloat, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.shadowRadius = value
        })
        return self
    }

    /// Sets the `shadowOpacity` to the intended `value`.
    @discardableResult
    public func shadowOpacity(_ value: Float, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.shadowOpacity = value
        })
        return self
    }

    /// Sets the `shadowPath` to the intended `value`.
    @discardableResult
    public func shadowPath(_ value: CGPath?, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.shadowPath = value
        })
        return self
    }

    /// Sets the `transform` to the intended `value`.
    @discardableResult
    public func transform(_ value: CATransform3D, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.transform = value
        })
        return self
    }

    /// Sets the `backgroundColor` to the intended `value`.
    @discardableResult
    public func backgroundColor(_ value: UIColor?, _ condition: Condition? = nil) -> Animations {
        animations.append(Animation(condition: condition) { viewState in
            viewState.backgroundColor = value
        })
        return self
    }

    public enum Direction {
        case up(CGFloat)
        case down(CGFloat)
        case left(CGFloat)
        case right(CGFloat)
    }
    
    /// The infomation provided to a `Condition`
    public struct Filter {
        public let mode: Mode
        public let toViewControllerType: UIViewController.Type?
        public let fromViewControllerType: UIViewController.Type?
        
        public enum Mode {
            case onAppear
            case onDisappear
        }
        
        public var isAppear: Bool {
            mode == .onAppear
        }
        
        public var isDisappear: Bool {
            mode == .onDisappear
        }
    }
    
    /// Applies the animations to the view state.
    func apply(to viewState: inout ViewState, filter: Filter) {
        animations.forEach { animation in
            guard animation.condition == nil || animation.condition?.predicate(filter) == true else { return }
            animation.apply(&viewState)
        }
    }
    
    func copy() -> Animations {
        return Animations(animations: animations)
    }
}
