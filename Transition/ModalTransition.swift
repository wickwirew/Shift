//
//  Middleware.swift
//  Transition
//
//  Created by Wes Wickwire on 10/7/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

public enum ModalTransition {
    
    case fade
    case slide(Direction)
    
    public enum Direction {
        case up
        case down
        case left
        case right
    }
}

func modalTransitionMiddlware(for viewController: UIViewController) -> Middleware {
    let transition = viewController.shift.modalTransition ?? .fade
    
    switch transition {
    case .fade:
        return fade
    case .slide(let direction):
        return slide(direction: direction, frame: viewController.view.bounds)
    }
}

private var fade: Middleware {
    return { views in
        views.topRootView?.options.animations = [.fade]
    }
}

private func slide(direction: ModalTransition.Direction, frame: CGRect) -> Middleware {
    return { views in
        switch direction {
        case .up:
            views.topRootView?.options.animations = [.move(.up(frame.height))]
        case .down:
            views.topRootView?.options.animations = [.move(.down(frame.height))]
        case .left:
            views.topRootView?.options.animations = [.move(.left(frame.width))]
        case .right:
            views.topRootView?.options.animations = [.move(.right(frame.width))]
        }
    }
}
