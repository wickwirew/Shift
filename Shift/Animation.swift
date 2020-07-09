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
    typealias Animation = (inout ViewState) -> Void
    
    /// The aggregated list of animations to apply
    private var animations = [Animation]()
    
    var isEmpty: Bool {
        return animations.isEmpty
    }
    
    /// Fades the view.
    @discardableResult
    public func fade() -> Animations {
        animations.append { viewState in
            viewState.alpha = 0
        }
        return self
    }
    
    /// Scales the view by the `value`
    @discardableResult
    public func scale(_ value: CGFloat) -> Animations {
        animations.append { viewState in
            viewState.transform = CATransform3DScale(viewState.transform, value, value, value)
        }
        return self
    }
    
    /// Moves the view from the destination position.
    /// - Parameters:
    ///   - direction: The direction and value to move.
    @discardableResult
    public func move(_ direction: Direction) -> Animations {
        switch direction {
        case .up(let value):
            return move(x: 0, y: value)
        case .down(let value):
            return move(x: 0, y: -value)
        case .left(let value):
            return move(x: value, y: 0)
        case .right(let value):
            return move(x: -value, y: 0)
        }
    }
    
    /// Moves the view from the destination position.
    /// - Parameters:
    ///   - x: The delta for the x axis
    ///   - y: The delta for the y axis
    @discardableResult
    public func move(x: CGFloat, y: CGFloat) -> Animations {
        animations.append { viewState in
            viewState.position.x += x
            viewState.position.y += y
        }
        return self
    }
    
    /// Sets the `bounds` to the intended `value`.
    @discardableResult
    public func bounds(_ value: CGRect) -> Animations {
        animations.append { viewState in
            viewState.bounds = value
        }
        return self
    }

    /// Sets the `alpha` to the intended `value`.
    @discardableResult
    public func alpha(_ value: CGFloat) -> Animations {
        animations.append { viewState in
            viewState.alpha = value
        }
        return self
    }

    /// Sets the `cornerRadius` to the intended `value`.
    @discardableResult
    public func cornerRadius(_ value: CGFloat) -> Animations {
        animations.append { viewState in
            viewState.cornerRadius = value
        }
        return self
    }

    /// Sets the `anchorPoint` to the intended `value`.
    @discardableResult
    public func anchorPoint(_ value: CGPoint) -> Animations {
        animations.append { viewState in
            viewState.anchorPoint = value
        }
        return self
    }

    /// Sets the `zPosition` to the intended `value`.
    @discardableResult
    public func zPosition(_ value: CGFloat) -> Animations {
        animations.append { viewState in
            viewState.zPosition = value
        }
        return self
    }

    /// Sets the `opacity` to the intended `value`.
    @discardableResult
    public func opacity(_ value: Float) -> Animations {
        animations.append { viewState in
            viewState.opacity = value
        }
        return self
    }

    /// Sets the `isOpaque` to the intended `value`.
    @discardableResult
    public func isOpaque(_ value: Bool) -> Animations {
        animations.append { viewState in
            viewState.isOpaque = value
        }
        return self
    }

    /// Sets the `masksToBounds` to the intended `value`.
    @discardableResult
    public func masksToBounds(_ value: Bool) -> Animations {
        animations.append { viewState in
            viewState.masksToBounds = value
        }
        return self
    }

    /// Sets the `borderColor` to the intended `value`.
    @discardableResult
    public func borderColor(_ value: CGColor?) -> Animations {
        animations.append { viewState in
            viewState.borderColor = value
        }
        return self
    }

    /// Sets the `borderWidth` to the intended `value`.
    @discardableResult
    public func borderWidth(_ value: CGFloat) -> Animations {
        animations.append { viewState in
            viewState.borderWidth = value
        }
        return self
    }

    /// Sets the `contentsRect` to the intended `value`.
    @discardableResult
    public func contentsRect(_ value: CGRect) -> Animations {
        animations.append { viewState in
            viewState.contentsRect = value
        }
        return self
    }

    /// Sets the `contentsScale` to the intended `value`.
    @discardableResult
    public func contentsScale(_ value: CGFloat) -> Animations {
        animations.append { viewState in
            viewState.contentsScale = value
        }
        return self
    }

    /// Sets the `shadowColor` to the intended `value`.
    @discardableResult
    public func shadowColor(_ value: CGColor?) -> Animations {
        animations.append { viewState in
            viewState.shadowColor = value
        }
        return self
    }

    /// Sets the `shadowOffset` to the intended `value`.
    @discardableResult
    public func shadowOffset(_ value: CGSize) -> Animations {
        animations.append { viewState in
            viewState.shadowOffset = value
        }
        return self
    }

    /// Sets the `shadowRadius` to the intended `value`.
    @discardableResult
    public func shadowRadius(_ value: CGFloat) -> Animations {
        animations.append { viewState in
            viewState.shadowRadius = value
        }
        return self
    }

    /// Sets the `shadowOpacity` to the intended `value`.
    @discardableResult
    public func shadowOpacity(_ value: Float) -> Animations {
        animations.append { viewState in
            viewState.shadowOpacity = value
        }
        return self
    }

    /// Sets the `shadowPath` to the intended `value`.
    @discardableResult
    public func shadowPath(_ value: CGPath?) -> Animations {
        animations.append { viewState in
            viewState.shadowPath = value
        }
        return self
    }

    /// Sets the `transform` to the intended `value`.
    @discardableResult
    public func transform(_ value: CATransform3D) -> Animations {
        animations.append { viewState in
            viewState.transform = value
        }
        return self
    }

    /// Sets the `backgroundColor` to the intended `value`.
    @discardableResult
    public func backgroundColor(_ value: UIColor?) -> Animations {
        animations.append { viewState in
            viewState.backgroundColor = value
        }
        return self
    }

    public enum Direction {
        case up(CGFloat)
        case down(CGFloat)
        case left(CGFloat)
        case right(CGFloat)
    }
    
    /// Applies the animations to the view state.
    func apply(to viewState: inout ViewState) {
        animations.forEach { $0(&viewState) }
    }
}
