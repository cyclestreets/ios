//
//  MenuSection.swift
//  CycleStreets
//
//  Created by Neil Edwards on 03/10/2018.
//  Copyright © 2018 cyclestreets. All rights reserved.
//

import Foundation

enum MenuSectionType{
    
    
}

enum MenuItemType{
    case journeyplanner
    case photomap
    case places
    case ridetracker
    case data
    
    case collisions
    case traffic
    case cycletheft
    case cycleability
    case planning
    case groups
    
    case mapstyle
    case settings
    case blog
    case feedback
    case account
    
    func items()->Array<MenuItem>?{
        switch self {
        case .data:
            
            var arr=[MenuItem]()
            arr.append(MenuItem(type: .collisions))
            arr.append(MenuItem(type: .traffic))
            arr.append(MenuItem(type: .cycletheft))
            arr.append(MenuItem(type: .cycleability))
            arr.append(MenuItem(type: .planning))
            arr.append(MenuItem(type: .groups))
            return arr
            
        default: return nil 
        }
    }
}


enum MenuActionType{
    case section
    case item
    case action
}

class MenuItem {
    
    var type:MenuItemType?
    var action:MenuActionType?
    
    var selected:Bool=false
    var expanded:Bool=false
    
    var items:Array<MenuItem>?
    var isExpandable:Bool{
        return items != nil ? true : false
    }
    
    init(type:MenuItemType, items:Array<MenuItem>?=nil) {
        self.type=type
        self.items=items
    }
    
    
    
}

