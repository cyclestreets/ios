//
//  NSObject+Additions.swift
//
//  Created by Neil Edwards on 26/10/2015.
//

import Foundation
import UIKit

extension NSObject{
    
    
    static func nib()->UINib{
        
        let classBundle:Bundle=Bundle(for: self.classForCoder())
        return UINib(nibName: self.nibName(), bundle: classBundle)
        
    }
    
    
    static func nibName()->String{
        
        let stringToReplace="View"
        
        let className:NSString=self.className() as NSString
        
        return className.replacingOccurrences(of: stringToReplace, with: "", options: .backwards, range: NSRange(location: self.className().count-stringToReplace.count, length: stringToReplace.count))
        
    }
    
    
    static func className()->String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    func className()->String{
        return self.nameOfClass;
    }
    
    
    
    public var nameOfClass: String{
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
    
    
    
    public func callSelectorAsync(_ selector: Selector, object: AnyObject?, delay: TimeInterval) -> Timer {
        
        let timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: selector, userInfo: object, repeats: false)
        return timer
    }
    
    public func callSelector(_ selector: Selector, object: AnyObject?, delay: TimeInterval) {
        
        let delay = delay * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            Thread.detachNewThreadSelector(selector, toTarget:self, with: object)
        })
    }

    
}
