//
//  DrawerController.swift
//  CycleStreets
//
//  Created by Neil Edwards on 05/10/2018.
//  Copyright © 2018 cyclestreets. All rights reserved.
//

import Foundation
import UIKit
import PureLayout


class CSScrollView:UIScrollView{
    
    var contentView:UIView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView=super.hitTest(point, with: event)
        if hitView==contentView!{
            return hitView
        }
        return nil
    }
    
    func isInsideSubView(_ point: CGPoint)->Bool{
        let convertedPoint=contentView?.convert(point, from: superview!)
        let hitView=super.hitTest(convertedPoint!, with: nil)
        return hitView==contentView
    }
    
}

class DrawerController:UIViewController{
    
    @IBOutlet weak var contentScrollView:CSScrollView!
    
    var activeDrawer:DrawerChildProtocol?
    
    var touchTarget:UIView?
    
    // new drawer controllers are added to this scroll view
    // we control initial offset and limit it to drawer page height
    // will need keyboard detection for drawers
    // can handle close and open animations within the scroll view
    
    // drawers can be scrolled off screen but never on screen more than their height
    
    
}



extension DrawerController{
    
    
    func addDrawerChild(){
        
        
        let controller=self.storyboard?.instantiateViewController(withIdentifier: "LoginDrawerController") as! LoginDrawerController
        
        let contentView=controller.view
        contentScrollView.addSubview(contentView!)
        contentView?.height=400
        activeDrawer=controller
        
        let v=self.view as? TKPassThroughView
        v?.contentScrollView=contentScrollView
        
        contentScrollView.contentInset=UIEdgeInsets(top: self.view.height-80, left: 0, bottom: 0, right: 0)  // top is the initial offset, sets the initial display location, cna be very low so you can scroll the drawer almost off screen
        contentScrollView.contentSize=CGSize(width: self.view.width, height: 400) // height is the height of the drawer, this stops the bottom edge fo the drawer showing
        
        contentScrollView.contentView=contentView
        
        
    }
    
    
}


extension DrawerController:UIScrollViewDelegate{
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        
        
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        
        
        
    }
    
    
}
