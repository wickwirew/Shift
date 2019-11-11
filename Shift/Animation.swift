//
//  Animation.swift
//  Transition
//
//  Created by Wes Wickwire on 10/3/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

public enum Animation {
    
    case move(x: CGFloat, y: CGFloat)
    case bounds(CGRect)
    case alpha(CGFloat)
    case cornerRadius(CGFloat)
    case anchorPoint(CGPoint)
    case zPosition(CGFloat)
    case opacity(Float)
    case isOpaque(Bool)
    case masksToBounds(Bool)
    case borderColor(CGColor?)
    case borderWidth(CGFloat)
    case contentsRect(CGRect)
    case contentsScale(CGFloat)
    case shadowColor(CGColor?)
    case shadowOffset(CGSize)
    case shadowRadius(CGFloat)
    case shadowOpacity(Float)
    case shadowPath(CGPath?)
    case transform(CATransform3D)
    case backgroundColor(UIColor?)
    case custom((inout ViewState) -> Void)
    
    public static var fade: Animation {
        return .alpha(0)
    }
    
    public static func move(_ direction: Direction) -> Animation {
        switch direction {
        case .up(let value):
            return .move(x: 0, y: value)
        case .down(let value):
            return .move(x: 0, y: -value)
        case .left(let value):
            return .move(x: value, y: 0)
        case .right(let value):
            return .move(x: -value, y: 0)
        }
    }
    
    public static func scale(_ value: CGFloat) -> Animation {
        return .custom { state in
            state.transform = CATransform3DScale(state.transform, value, value, value)
        }
    }
    
    func apply(to state: inout ViewState) {
        switch self {
        case .move(let x, let y):
            state.position.x += x
            state.position.y += y
        case .bounds(let value):
            state.bounds = value
        case .alpha(let value):
            state.alpha = value
        case .cornerRadius(let value):
            state.cornerRadius = value
        case .anchorPoint(let value):
            state.anchorPoint = value
        case .zPosition(let value):
            state.zPosition = value
        case .opacity(let value):
            state.opacity = value
        case .isOpaque(let value):
            state.isOpaque = value
        case .masksToBounds(let value):
            state.masksToBounds = value
        case .borderColor(let value):
            state.borderColor = value
        case .borderWidth(let value):
            state.borderWidth = value
        case .contentsRect(let value):
            state.contentsRect = value
        case .contentsScale(let value):
            state.contentsScale = value
        case .shadowColor(let value):
            state.shadowColor = value
        case .shadowOffset(let value):
            state.shadowOffset = value
        case .shadowRadius(let value):
            state.shadowRadius = value
        case .shadowOpacity(let value):
            state.shadowOpacity = value
        case .shadowPath(let value):
            state.shadowPath = value
        case .transform(let value):
            state.transform = value
        case .backgroundColor(let value):
            state.backgroundColor = value
        case .custom(let modifier):
            modifier(&state)
        }
    }
    
    public enum Direction {
        case up(CGFloat)
        case down(CGFloat)
        case left(CGFloat)
        case right(CGFloat)
    }
}

extension Array where Element == Animation {
    
    func apply(to state: inout ViewState) {
        forEach { $0.apply(to: &state) }
    }
}
