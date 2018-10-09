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
        
        // tableview setup
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createNonPersistentUI()
    }
    
    func createNonPersistentUI(){
        
        
        
    }
    
}


//MARK: - Table Updating for subsections
extension MenuController{
    
    
    func openSubSection(_ item:MenuItem){
        
        // if has sub menu items
        // call for new data insert
        // on return
        // insert new cells of type
        
        
    }
    
    
    
    
}



extension MenuController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let _=dataProvider?[indexPath.row]{
            
            // if section type check for subsections and if open
            // if no subsections execute action for type (will toggle overlay)
            // if item type execute action for type
            // if action type pass to action type controller for drawer display
            
        }
        
    }
    
}

extension MenuController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let _=dataProvider?[indexPath.row]{
            
            
        }
        
        // get correct cell type for dp.actionType
        
        // if
        
        return UITableViewCell()
        
    }
    
    
}
