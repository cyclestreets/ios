//
//  AppViewController.swift
//  CycleStreets
//
//  Created by Neil Edwards on 02/10/2018.
//  Copyright © 2018 cyclestreets. All rights reserved.
//

import UIKit
import Foundation
import LGSideMenuController

class AppViewController:LGSideMenuController  {
    
    
    override func leftViewWillLayoutSubviews(with size: CGSize) {
        super.leftViewWillLayoutSubviews(with: size)
        
        if !isLeftViewStatusBarHidden {
            leftView?.frame = CGRect(x: 0.0, y: 20.0, width: size.width, height: size.height - 20.0)
        }
    }
    
    override var isLeftViewStatusBarHidden: Bool {
        get {
            return super.isLeftViewStatusBarHidden
        }
        
        set {
            super.isLeftViewStatusBarHidden = newValue
        }
    }
    
    override func viewDidLoad() {
        
        isRightViewEnabled=false
        
        leftViewPresentationStyle = .slideAbove
        leftViewBackgroundBlurEffect = UIBlurEffect(style: .light)
        leftViewBackgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.05)
        
        isLeftViewStatusBarHidden=true
        
        rootViewCoverBlurEffectForLeftView=UIBlurEffect(style: .light)
        
    }
    
}
