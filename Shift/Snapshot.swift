//
//  TransitionView.swift
//  Transition
//
//  Created by Wes Wickwire on 10/9/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

final class Snapshot: UIView {
    
    private let finalContent: UIView?
    private let initialContent: UIView?
    private let sizing: ShiftViewOptions.ContentSizing
    private let animation: ShiftViewOptions.ContentAnimation
    
    init(finalContent: UIView?,
         initialContent: UIView?,
         sizing: ShiftViewOptions.ContentSizing,
         animation: ShiftViewOptions.ContentAnimation) {
        
        self.finalContent = finalContent?.snapshot()
        switch animation {
        case .fade:
            self.initialContent = initialContent?.snapshot()
        case .final:
            self.initialContent = nil
        }
        
        self.sizing = sizing
        self.animation = animation
        super.init(frame: .zero)
        self.initialContent.map(addSubview)
        self.finalContent.map(addSubview)
    }
    
    func setContentAnimationStart() {
        
        switch animation {
        case .fade:
            finalContent?.alpha = 0
            initialContent?.alpha = 1
        case .final:
            break
        }
    }
    
    func setContentAnimationEnd() {
        switch animation {
        case .fade:
            finalContent?.alpha = 1
            initialContent?.alpha = 0
        case .final:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard sizing == .stretch else { return }
        finalContent?.frame = bounds
        initialContent?.frame = bounds
    }
}
