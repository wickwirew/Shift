//
//  DefaultShiftAnimation.swift
//  Shift
//
//  Created by Wes Wickwire on 7/11/20.
//  Copyright © 2020 Wes Wickwire. All rights reserved.
//

import UIKit

public protocol DefaultShiftAnimation {
    func apply(to views: ShiftViews, isPresenting: Bool)
}

public enum DefaultAnimations {
    
    public struct Fade: DefaultShiftAnimation {
        public init() {}
        public func apply(to views: ShiftViews, isPresenting: Bool) {
            views.sourceViewRoot?.animations.fade()
        }
    }
    
    public struct Scale: DefaultShiftAnimation {
        let amount: CGFloat
        
        public enum Direction {
            case up
            case down
        }
        
        public init(_ direction: DefaultAnimations.Scale.Direction = .down) {
            self.amount = direction == .down ? 1.7 : 0.7
        }
        
        public init(_ amount: CGFloat) {
            self.amount = amount
        }
        
        public func apply(to views: ShiftViews, isPresenting: Bool) {
            views.sourceViewRoot?.animations.fade().scale(amount)
        }
    }
}
