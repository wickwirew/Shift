//
//  ContentAnimation.swift
//  Transition
//
//  Created by Wes Wickwire on 10/1/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

/// How the the content, i.e. the subviews, shoud be handled
/// during the animation.
public enum ContentSizing {
    
    /// Content will be stretched.
    case stretch
    
    /// Content will be in its final state
    case final
}

public enum ContentAnimation {
    
    case fade
    
    case none
}
