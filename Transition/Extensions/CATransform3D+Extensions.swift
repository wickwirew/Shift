//
//  CATransform3D+Extensions.swift
//  Transition
//
//  Created by Wes Wickwire on 9/24/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import UIKit

extension CATransform3D: Equatable {
    
    public static func == (lhs: CATransform3D, rhs: CATransform3D) -> Bool {
        return lhs.m11 == rhs.m11
            && lhs.m12 == rhs.m12
            && lhs.m13 == rhs.m13
            && lhs.m14 == rhs.m14
            && lhs.m21 == rhs.m21
            && lhs.m22 == rhs.m22
            && lhs.m23 == rhs.m23
            && lhs.m24 == rhs.m24
            && lhs.m31 == rhs.m31
            && lhs.m32 == rhs.m32
            && lhs.m33 == rhs.m33
            && lhs.m34 == rhs.m34
            && lhs.m41 == rhs.m41
            && lhs.m42 == rhs.m42
            && lhs.m43 == rhs.m43
            && lhs.m44 == rhs.m44
    }
}
