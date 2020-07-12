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
    /// The identifier used to find matches.
    public var id: String?
    /// How the content will be sized during the transition.
    /// If a view changes size during the transition, you can define
    /// how that should be handled here.
    public var contentSizing: ContentSizing = .stretch
    /// How the content will be animated.
    /// This is only valid for matched items.
    public var contentAnimation: ContentAnimation = .fade
    /// Any additional animations to apply.
    public var animations = Animations()
    /// What should be the superview of the view during the transition.
    /// For matched items, they will automatically be put in the `container`
    public var superview: Superview = .parent
    /// Whether or not the view is hidden in the transition.
    public var isHidden: Bool = false
    /// How the view is positioned.
    /// This is along the z axis.
    public var position: Position = .auto
    
    /// Whether or not the view needs to be independently
    /// animated during the transition.
    var requiresAnimation: Bool {
        return id != nil
            || !animations.isEmpty
            || superview == .container
    }
    
    /// Gets a copy of the options that we can mutate without
    /// affecting the original view.
    /// Some of the properties are reference types and not passed by
    /// value so we need to do this manually.
    func copy() -> ShiftViewOptions {
        var result = self
        result.animations = animations.copy()
        return result
    }
    
    /// What should be the superview of the view during the transition.
    public enum Superview {
        /// The view will be added to the transition container.
        case container
        /// The view will be added to the views normal superview.
        case parent
    }

    /// How the view is positioned.
    /// This is along the z axis.
    public enum Position {
        /// The view will live its normal position.
        /// i.e. it will be (about) where it is in the actual view.
        case auto
        /// View will be moved to the front.
        case front
        /// View will be moved to the back.
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

    /// How the content will be animated.
    /// This is only valid for matched items.
    public enum ContentAnimation {
        /// The content will be faded from the start content to the final content.
        case fade
        /// There will be no animation. It will just always be in the final state.
        case final
    }
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
