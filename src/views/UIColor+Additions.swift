//
//  UIColor+Additions.swift
//
//  Created by Neil Edwards on 25/10/2015.
//  Copyright © 2015 buffer. All rights reserved.
//

import Foundation
import UIKit



extension UIColor{
    
    
    class func hexColor(_ hexString: String, _ alpha: CGFloat = 1.0) -> UIColor? {
        return UIColor.colorWithHexString(hexString, alpha: alpha)
    }
    
    
    class func colorWithHexString( _ string:String, alpha:CGFloat)->UIColor?{
        
        var string=string
        guard string.characters.count != 0 else {return nil}
        
        if(string.characters.first != "#"){
            string=String(format: "#%@", string)
        }
        
        guard string.characters.count != 7 || string.characters.count != 4 else { return nil }
        
        if(string.characters.count==4){
            
            string=String(format: "#%@%@%@%@%@%@",
            (string as NSString).substring(with: NSRange(location: 1, length: 1)),(string as NSString).substring(with: NSRange(location: 1, length: 1)),
            (string as NSString).substring(with: NSRange(location: 2, length: 1)),(string as NSString).substring(with: NSRange(location: 2, length: 1)),
            (string as NSString).substring(with: NSRange(location: 3, length: 1)),(string as NSString).substring(with: NSRange(location: 3, length: 1)))
            
        }
        
        let redHex:String=String(format: "0x%@", (string as NSString).substring(with: NSRange(location: 1, length: 2)))
        let red:CUnsignedInt=UIColor.hexValueToUnsigned(redHex)
        
        let greenHex:String=String(format: "0x%@", (string as NSString).substring(with: NSRange(location: 3, length: 2)))
        let green:CUnsignedInt=UIColor.hexValueToUnsigned(greenHex)
        
        let blueHex:String=String(format: "0x%@", (string as NSString).substring(with: NSRange(location: 5, length: 2)))
        let blue:CUnsignedInt=UIColor.hexValueToUnsigned(blueHex)
    
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: alpha)
        
    }
    
    
    class func hexValueToUnsigned(_ string:String)->CUnsignedInt{
        
        var value:CUnsignedInt=0
        
        let scanner:Scanner=Scanner(string: string)
        scanner.scanHexInt32(&value)
        
        return value
        
    }
    
    
    class func colorWithAlpha(_ color:UIColor,alpha:CGFloat)->UIColor{
    
        return color.withAlphaComponent(alpha)
    
    }
    
    
    class func random()->UIColor{
        
        let red:CGFloat=CGFloat(arc4random()) / CGFloat(UInt32.max)
        let green:CGFloat=CGFloat(arc4random()) / CGFloat(UInt32.max)
        let blue:CGFloat=CGFloat(arc4random()) / CGFloat(UInt32.max)
        
        let color=UIColor(red:red , green:green, blue: blue, alpha: 1.0)
        return color
    }
    
    
    
}

