//
//  NSLayoutConstraintExtensions.swift
//
//  Created by Neil Edwards on 19/01/2016.
//  Copyright © 2016 buffer. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    
    
    func constraintsForAttribute(_ attribute:NSLayoutAttribute)->Array<NSLayoutConstraint>{
        
       // logger.debug("\(attribute.rawValue)")
        
        let arr:[NSLayoutConstraint]=self.constraints.filter({$0.firstAttribute.rawValue == attribute.rawValue})
        
        return arr
        
    }
    
    
    func constraintForAttribute(_ attribute:NSLayoutAttribute)->NSLayoutConstraint?{
        
        let constraints:[NSLayoutConstraint]=self.constraintsForAttribute(attribute)
        
        guard constraints.count>0  else {return nil}
        
        return constraints.first
        
    }
    
	func constraintWithView(view:UIView, attribute:NSLayoutAttribute) -> NSLayoutConstraint? {
		
		for constraint in self.constraints {
			
			//Guard for the constraints concerning the views we care about
			guard let secondItem = constraint.secondItem as? UIView else { continue }
			guard secondItem == view || constraint.firstItem as? UIView == view else { continue }
			
			if (constraint.firstAttribute == attribute && constraint.firstItem as? UIView == view) {
				return constraint
			} else if (secondItem == view && constraint.secondAttribute == attribute) {
				return constraint
			}
		}
		
		
		print("Unable to find constraint for attribute: \(attribute)")
		return nil
	}
    
	
    
}
