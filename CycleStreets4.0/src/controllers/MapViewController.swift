//
//  MapViewController.swift
//  CycleStreets
//
//  Created by Neil Edwards on 01/10/2018.
//  Copyright © 2018 cyclestreets. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import PureLayout
import Presentr

class MapViewController:UIViewController{
    
    
    @IBOutlet weak var mapView: MKMapView!
    
   // var annotations:Array=[]
    
    var mapChangedFromUserInteraction:Bool=false // map View was changed form user interaction not programmtic
    var shouldAcceptLocationUpdates:Bool=true // mapView should accept gps updates
    
    
    
    
    
    //MARK: - UIViewController
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.createPersistentUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
      //  self.createNonPersistentUI()
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
//        if let selectedLocation=self.selectedLocation{
//            self.displayCalloutForLocation(selectedLocation)
//        }
        
        
    }
    
    
    
    /**
     Initial one-time View setup
     */
    func createPersistentUI(){
        
        
//        mapView.delegate=self
//        
//        
//        self.createNavigationBarUI()
//        
//        self.listNotificationInterests()
        
        
        
        let drawer=self.storyboard?.instantiateViewController(withIdentifier: "DrawerController") as! DrawerController
        self.addChild(drawer)
        self.view.addSubview(drawer.view)
        drawer.view.autoPinEdgesToSuperviewEdges()
        drawer.didMove(toParent: self)
        drawer.touchTarget=self.view
        
        drawer.addDrawerChild()
        
        
    }
    
    
    
}



// annotations will be encapsulated in a contoller for each type
// then we can call get annotations on a Controller
// annotation selection can be passed to the appropriate controller too
// 


//MARK: - UI Events
extension MapViewController{
    
    @IBAction func didSelectMenuButton(){
        sideMenuController?.showLeftView(animated: true, completionHandler: nil)
    }
    
    
}


extension MapViewController{
    
    
    /**
     Returns wether the map movement was from user interaction or from the location updates
     - returns:             Bool : map movement was from user Interaction
     */
    func mapViewRegionDidChangeFromUserInteraction()->Bool{
        
        if let view:UIView=mapView.subviews.first{
            for recogniser:UIGestureRecognizer in view.gestureRecognizers!{
                if recogniser.state == .began || recogniser.state == .ended{
                    return true
                }
            }
        }
        return false
        
    }
    
    
}
