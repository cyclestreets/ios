//
//  PassthroughView.swift
//  CycleStreets
//
//  Created by Neil Edwards on 09/10/2018.
//  Copyright © 2018 cyclestreets. All rights reserved.
//

import Foundation
import UIKit

class TKPassThroughView: UIView {
    
    // MARK - Touch Handling
    var contentScrollView:CSScrollView?
    /**
     Override this point and determine if any of the subviews of our transparent view are the ones being tapped. If that is the case, handle those touches otherwise pass the touch through.
     */
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let contentScrollView=contentScrollView{
            return contentScrollView.isInsideSubView(point)
        }
        return false
    }
}
