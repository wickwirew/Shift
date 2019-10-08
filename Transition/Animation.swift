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
    case translate(x: CGFloat = 0, y: CGFloat = 0)
    
    func apply(to state: inout ViewState) {
        switch self {
        case .fade:
            state.alpha = 0
        case let .translate(x, y):
            state.position.x -= x
            state.position.y += y
        }
    }
}

extension Array where Element == Animation {
    
    func apply(to state: inout ViewState) {
        forEach { $0.apply(to: &state) }
    }
}
