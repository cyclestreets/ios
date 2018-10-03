//
//  UIViewBUExtension.swift
//
//  Created by Neil Edwards on 24/10/2015.
//

import Foundation
import UIKit



extension UIView{
    
    
    @objc var height:CGFloat{
        
        get{
            return self.frame.height
        }
        
        set{
            self.frame.size.height=newValue
        }
        
    }
        
    @objc var width:CGFloat{
        
        get{
            return self.frame.width
        }
        
        set{
           self.frame.size.width=newValue
        }
        
    }
    
    @objc var size:CGSize{
        
        get{
            return self.frame.size
        }
        
        set{
            self.frame.size=newValue
        }
        
    }
    
    
    @objc var x:CGFloat{
        
        get{
            return self.frame.minX;
        }
        set{
            self.frame.origin.x=newValue
        }
    }
    
    @objc var y:CGFloat{
        
        get{
            return self.frame.minY;
        }
        set{
            self.frame.origin.y=newValue
        }
    }
    
    @objc var bottom:CGFloat{
        
        get{
            return self.frame.maxY;
        }
        set{
            self.frame.origin.y=newValue-self.height
        }
    }
    
    // not really needed but for completeness sake
    @objc var top:CGFloat{
        
        get{
            return self.y;
        }
        set{
            self.y=newValue
        }
    }
    
    
    func removeAllSubViews(){
        
        self.subviews.forEach({
            $0.removeFromSuperview()
        })
        
    }
    
    
    func viewSnapshotImage()->UIImage{
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let viewImage:UIImage=UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return viewImage
        
    }
    
    
    var visible:Bool{
        
        get{ return !self.isHidden}
        set{self.isHidden = !newValue}
        
    }
    
    
    class func logRect(_ rect:CGRect){
        
        print("(%0.0f,%0.0f),(%0.0f,%0.0f)",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height)
        
    }
    
    
    func shake(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
    
    
    func findFirstSuperview<T>(ofClass viewClass: T.Type, where predicate: (T) -> Bool) -> T? where T: UIView {
        var view: UIView? = self
        while view != nil {
            if let typedView = view as? T, predicate(typedView) {
                break
            }
            
            view = view?.superview
        }
        
        return view as? T
    }
    
    
    class func loadInstanceOfView(_ className:AnyClass,nibName:String)->AnyObject? {
        
        var obj:AnyObject?=nil
        
        let arr:Array=Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)!
        arr.forEach ({
            if(($0 as AnyObject).isKind(of: className)){
                obj=$0 as AnyObject?
            }
            
        })
        
        return obj
    }
    
    
    class func loadInstanceOfView(_ className:AnyClass,nibName:String, owner:AnyObject)->AnyObject? {
        
        var obj:AnyObject?=nil
        
        let arr:Array=Bundle.main.loadNibNamed(nibName, owner: owner, options: nil)!
        arr.forEach ({
            if(($0 as AnyObject).isKind(of: className)){
                obj=$0 as AnyObject?
            }
            
        })
        
        return obj
    }
    
    
}
