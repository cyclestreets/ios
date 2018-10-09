//
//  APIRequestor.swift
//  CycleStreets
//
//  Created by Neil Edwards on 06/10/2018.
//  Copyright © 2018 cyclestreets. All rights reserved.
//

import Foundation
import Alamofire

enum RequestType{
    case login
    case logout
    case adherence
    case remedy
}

struct APIRequest{
    
    var type:RequestType
    var params:Dictionary<String,String>?
    var urlParams:Array<String>?
    
    init(requesttype:RequestType,requestparams:Dictionary<String,String>?=nil, urlparams:Array<String>?=nil) {
        type=requesttype
        params=requestparams
        urlParams=urlparams
    }
    
    
    func url()->String{
        
        return ""
    }
    
    func method()->String{
        return ""
    }
    
    
}

class APIRequestor {
    
    static let sharedInstance=APIRequestor()
    var sessionManager:SessionManager?
    
    var apiToken:String?
    
    init() {
        self.sessionManager = Alamofire.SessionManager(configuration: .default)
    }
    
    public func perfomAPIRequest(_ request:APIRequest,result: @escaping (_ result:Data?, _ error:Error?)->Void){
        
        self.sessionManager?.request(request.url() , method: .post, parameters: request.params, encoding:JSONEncoding.default,headers:nil).validate().responseJSON {
            (response) in
            
            // result(nil,error);
            
        }
        
    }
    
    
    
}
