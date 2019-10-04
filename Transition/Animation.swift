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
    case translate(y: CGFloat)
    
    func apply(to state: inout TransitionViewState) {
        switch self {
        case .fade:
            state.alpha = 0
        case let .translate(y):
            state.position.y += y
        }
    }
}

extension Array where Element == Animation {
    
    func apply(to state: inout TransitionViewState) {
        forEach { $0.apply(to: &state) }
    }
}
