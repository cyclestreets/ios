//
//  AppVersionUtility.swift
//
//  Created by Neil Edwards on 13/06/2018.
//

import Foundation


class AppVersionUtility{
    
    static let sharedInstance=AppVersionUtility()
    
    public private(set) var isNewVersion: Bool=false
    
    private init(){}
    
    // will update stored version value and provide runtime value for when this app launch
    // was from a new app version
    func checkAppVersion(){
        let defaults=UserDefaults.standard
        if let appVersion=defaults.object(forKey: UserDefaultsConstants.AppVersion){
            
            if let bundleDict=Bundle.main.infoDictionary,
                let versionString=bundleDict["CFBundleShortVersionString"]{
                let appVersionString = appVersion as! String
                if appVersionString.compare(versionString as! String, options: .numeric, range: nil, locale: nil) != .orderedDescending{
                    defaults.set(appVersionString, forKey: UserDefaultsConstants.AppVersion)
                    isNewVersion=true
                }
                
            }
            
        }
        
    }
    
    
    static func AppVersionisAbove(_ version:String)->Bool{
        
        if let bundleDict=Bundle.main.infoDictionary,
            let versionString=bundleDict["CFBundleShortVersionString"]{
            if version.compare(versionString as! String, options: .numeric, range: nil, locale: nil) != .orderedDescending {
               return true
            }
            
        }
        
        return false
    }
}
