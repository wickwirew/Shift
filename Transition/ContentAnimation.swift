//
//  ContentAnimation.swift
//  Transition
//
//  Created by Wes Wickwire on 10/1/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

/// How the the content, i.e. the subviews, shoud be handled
/// during the animation.
public enum ContentAnimation {
    
    /// Content will be stretched.
    case stretch
    
    /// Content will fade in.
    case fade
    
    /// Content will not be shown during the animation
    /// and will reappear at the end.
    case ignore
}
