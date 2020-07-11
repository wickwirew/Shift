//
//  Animation.swift
//  ExpandoCell
//
//  Created by Wes Wickwire on 9/17/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import Foundation
import UIKit

public struct ShiftViewOptions {
    public var id: String?
    public var contentSizing: ContentSizing = .stretch
    public var contentAnimation: ContentAnimation = .fade
    public var animations = Animations()
    public var superview: ShiftSuperview = .parent
    public var isHidden: Bool = false
    public var position: ShiftPosition = .auto
    
    /// Whether or not the view needs to be independently
    /// animated during the transition.
    var requiresAnimation: Bool {
        return id != nil
            || !animations.isEmpty
            || superview == .container
    }
}

public enum ShiftSuperview {
    case container
    case parent
}

public enum ShiftPosition {
    case auto
    case front
    case back
}

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

extension UIView {
    
    private struct Keys {
        static var shift = "shift"
    }
    
    public var shift: ShiftViewOptions {
        get {
            return getOrCreateAssociatedObject(
                key: &Keys.shift,
                as: ShiftViewOptions.self,
                default: .init()
            )
        } set {
            setAssociatedObject(key: &Keys.shift, to: newValue)
        }
    }
}
