//
//  CALayer+Extensions.swift
//  ExpandoCell
//
//  Created by Wes Wickwire on 9/21/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

extension CALayer {
    
    func addAnimation(for keyPath: AnimationKeyPath,
                      from fromValue: Any?,
                      to toValue: Any?,
                      finalState: TransitionViewState) {
        let animation = CABasicAnimation(keyPath: keyPath.rawValue)
        animation.fromValue = fromValue
        animation.toValue = toValue
//        animation.duration = optimizedDuration(finalState: finalState)
        add(animation, forKey: keyPath.rawValue)
    }
//
//    func optimizedDuration(finalState: AnimationContext.ViewState) -> TimeInterval {
//        let fromPos = (self.presentation() ?? self).position
//        let toPos = finalState.position
//        let fromSize = (self.presentation() ?? self).bounds.size
//        let toSize = finalState.bounds.size
//        let fromTransform = (self.presentation() ?? self).transform
//        let toTransform = finalState.transform
//
//        let realFromPos = CGPoint.zero.transform(fromTransform) + fromPos
//        let realToPos = CGPoint.zero.transform(toTransform) + toPos
//
//        let realFromSize = fromSize.transform(fromTransform)
//        let realToSize = toSize.transform(toTransform)
//
//        let movePoints = (realFromPos.distance(realToPos) + realFromSize.bottomRight.distance(realToSize.bottomRight))
//
//        return 0.208 + Double(movePoints.clamp(0, 500)) / 3000
//    }
}
