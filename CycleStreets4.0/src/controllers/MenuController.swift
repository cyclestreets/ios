//
//  MenuController.swift
//  CycleStreets
//
//  Created by Neil Edwards on 01/10/2018.
//  Copyright © 2018 cyclestreets. All rights reserved.
//

import Foundation
import UIKit

class MenuController: UIViewController {
    
    var dataProvider:Array<MenuItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func createPersistentUI(){
        
        
        
    }
    
    
    func createNonPersistentUI(){
        
        
        
    }
    
}



extension MenuController:UITableViewDelegate{
    
}

extension MenuController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get dp
        
        // get correct cell type for dp.actionType
        
        // if
        
        return UITableViewCell()
        
    }
    
    
}
