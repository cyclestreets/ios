//
//  UIButton+Additions.swift
//
//  Created by Neil Edwards on 25/10/2015.
//

import Foundation
import UIKit


var dataProviderASKey: String = "dataProvider"


extension UIButton {

    
    var dataProvider:AnyObject?{
        get {
            return objc_getAssociatedObject(self, &dataProviderASKey) as AnyObject
        }
        set {
            objc_setAssociatedObject(self, &dataProviderASKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    
}

