//
//  MenuDataSource.swift
//  CycleStreets
//
//  Created by Neil Edwards on 03/10/2018.
//  Copyright © 2018 cyclestreets. All rights reserved.
//

import Foundation

class MenuDataSource{
    
    var itemDataProvider:Array<MenuItem>?
    
    
    
    func create(_  result: @escaping(_ success:Bool?, _ error:Error?)->Void){
        
        self.itemDataProvider=createMenuData()
        
        result(true,nil)
        
    }
    
    
    func createMenuData()->Array<MenuItem>{
        
        var arr=[MenuItem]()
        
        arr.append(MenuItem(type: .journeyplanner))
        arr.append(MenuItem(type: .photomap))
        arr.append(MenuItem(type: .places))
        arr.append(MenuItem(type: .ridetracker))
        
        arr.append(MenuItem(type: .data, items:MenuItemType.data.items()))
        
        arr.append(MenuItem(type: .mapstyle))
        arr.append(MenuItem(type: .settings))
        arr.append(MenuItem(type: .blog))
        arr.append(MenuItem(type: .feedback))
        arr.append(MenuItem(type: .account))
        
        return arr
        
        
    }
    
    
}
