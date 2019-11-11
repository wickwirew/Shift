//
//  NSObject+Extensions.swift
//  Transition
//
//  Created by Wes Wickwire on 10/7/19.
//  Copyright © 2019 Wes Wickwire. All rights reserved.
//

import Foundation

extension NSObject {
    
    func getOrCreateAssociatedObject<T>(key: inout String, as t: T.Type, default: T) -> T {
        if let value = objc_getAssociatedObject(self, &key) as? T {
            return value
        }
        
        let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        objc_setAssociatedObject(self, &key, `default`, nonatomic)
        return `default`
    }
    
    func getAssociatedObject<T>(key: inout String, as t: T.Type) -> T? {
        return objc_getAssociatedObject(self, &key) as? T
    }
    
    func setAssociatedObject<T>(key: inout String, to newValue: T) {
        let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        objc_setAssociatedObject(self, &key, newValue, nonatomic)
    }
}

