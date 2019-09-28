//
//  CGFloat+Extensions.swift
//  Transition
//
//  Created by Wes Wickwire on 9/27/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

extension CGFloat {
    
    func clamp(_ lower: CGFloat, _ upper: CGFloat) -> CGFloat {
        guard self > lower else { return lower }
        guard self < upper else { return upper }
        return self
    }
}
