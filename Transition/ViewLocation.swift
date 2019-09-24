//
//  ViewLocation.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

/// Lcoation of the view within the subview tree
struct ViewLocation: Comparable {
    
    let depth: Int
    let index: Int
    
    static func < (lhs: ViewLocation, rhs: ViewLocation) -> Bool {
        if lhs.depth == rhs.depth {
            return lhs.index < rhs.index
        }
        
        return lhs.depth < rhs.depth
    }
}
