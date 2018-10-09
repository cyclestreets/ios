//
//  LoginDrawerController.swift
//  CycleStreets4
//
//  Created by Neil Edwards on 05/10/2018.
//  Copyright © 2018 cyclestreets. All rights reserved.
//

import Foundation
import UIKit

protocol DrawerChildProtocol {
    
}

class LoginDrawerController: UIViewController,DrawerChildProtocol {
    
    var pageScrollView:UIScrollView?
    
    // each drawer contains a series of page controllers
    // each page communicates its height to the drawer which in turn tells the drawer container to show the full page height if required
    
}
