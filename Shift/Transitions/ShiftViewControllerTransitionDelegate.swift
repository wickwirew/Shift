//
//  ShiftViewControllerTransitionDelegate.swift
//
//
//  Created by Wes Wickwire on 2/11/24.
//

import UIKit

/// If the presented view controller conforms to this the hook functions will
/// be called automatically by the shift UIViewController transitions.
public protocol ShiftViewControllerTransitionDelegate {
    /// Called after all layout has been finished right before the animation starts
    func shiftAnimationWillBegin()
    /// Callled after the animation has completed.
    func shiftAnimationDidFinish()
}

public extension ShiftViewControllerTransitionDelegate {
    func shiftAnimationWillBegin() {}
    func shiftAnimationDidFinish() {}
}
