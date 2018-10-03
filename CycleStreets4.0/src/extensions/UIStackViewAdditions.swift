//
//  UIStackViewAdditions.swift
//
//  Created by Neil Edwards on 28/02/2018.
//

import Foundation
import UIKit

extension UIStackView{
	
	func removeAllArrangedSubViews(){
		
		for subview in self.arrangedSubviews{
			self.removeArrangedSubview(subview)
            subview.removeFromSuperview()
		}
		
	}
	
	
}

