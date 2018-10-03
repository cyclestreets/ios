//
//  ButtonActivity.swift
//
//  Created by Neil Edwards on 22/06/2017.
//

import Foundation
import UIKit
import PureLayout

var activityIndicatorASKey: String = "activityIndicator"

protocol ButtonActivity{}


extension ButtonActivity where Self:UIButton{
    
    var activityIndicator:UIActivityIndicatorView?{
        get {
            return objc_getAssociatedObject(self, &activityIndicatorASKey) as? UIActivityIndicatorView
        }
        set {
            objc_setAssociatedObject(self, &activityIndicatorASKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    mutating func showLoading() {
        
        if self.activityIndicator==nil{
            self.activityIndicator=createActivityIndicator()
        }
        
        showSpinning()
    }
    
    func hideLoading() {
        if let activityIndicator=self.activityIndicator{
            activityIndicator.stopAnimating()
        }
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.white
        return activityIndicator
    }
    
    private func showSpinning() {
        if let activityIndicator=self.activityIndicator{
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(activityIndicator)
            centerActivityIndicatorInButton()
            activityIndicator.startAnimating()
        }
    }
    
    private func centerActivityIndicatorInButton() {
        if let activityIndicator=self.activityIndicator{
            activityIndicator.autoPinEdge(.left, to: .left, of: self, withOffset: 7)
            activityIndicator.autoAlignAxis(.horizontal, toSameAxisOf: self)
        }
    }
    
    
    
}


