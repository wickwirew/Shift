//
//  Animation.swift
//  Transition
//
//  Created by Wes Wickwire on 10/3/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

public enum Animation {
    
    case fade
    case move(Direction)
    case color(UIColor)
    case scale(CGFloat)
    
    func apply(to state: inout ViewState) {
        switch self {
        case .fade:
            state.alpha = 0
        case let .move(direction):
            switch direction {
            case .up(let value):
                state.position.y += value
            case .down(let value):
                state.position.y -= value
            case .left(let value):
                state.position.x += value
            case .right(let value):
                state.position.x -= value
            }
        case .color(let color):
            state.backgroundColor = color
        case .scale(let value):
            state.transform = CATransform3DScale(state.transform, value, value, value)
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
