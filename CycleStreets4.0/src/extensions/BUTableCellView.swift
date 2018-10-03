//
//  BUTableCellView.swift
//
//  Created by Neil Edwards on 24/10/2015.
//

import Foundation
import UIKit


public typealias BUTableCellViewButtonBlock=(String,AnyObject)->()


protocol BUTableCellViewCore:class{

    func initialise()
    func populate()
    
    static func rowHeight()->Int

}

protocol BUTableCellViewButtonEvent:class{

    var cellButtonEventBlock:BUTableCellViewButtonBlock? { get set }

}


extension BUTableCellViewButtonEvent where Self:UITableViewCell{
    
    
    
    func cellButtonWasSelected(_ sender:AnyObject){}
    
    
    func sendCellButtonBlockWithEvent(_ event:String,dataProvider:AnyObject){
        
        if let _=cellButtonEventBlock{
            
            cellButtonEventBlock?(event,dataProvider)
            
        }
        
    }
    
}


extension BUTableCellViewCore where Self:UITableViewCell{
    
    
    func awakeFromNib(){
        self.awakeFromNib()
        self.initialise()
    }

    
    static func cellIdentifier()->String{
        return String(format: "%@Identifier", self.nibName())
    }
    
    static func rowHeight()->Int{
        return 44
    }
    
}



//class BUTableCellView:UITableViewCell,BUTableCellViewCore{
//    
//    
//    //MARK: - Instance
//    
//    override func awakeFromNib(){
//        
//        super.awakeFromNib()
//        self.initialise()
//        
//    }
//    
//    
//    
//}
