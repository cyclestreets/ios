//
//  MediaAccess.swift
//
//  Created by Neil Edwards on 08/08/2017.
//

import Foundation
import Photos

class MediaAccess{
    
    /// checks and returns if the user can access their camera, will invoke authorisation
    /// if not currently authorised or prompt user to allow access if previously denied
    ///
    /// - Parameter completion: allowed: you can access the camera
    class func requestCameraAuthorisation(completion:@escaping (_ allowed:Bool)->Void){
        
		let mediaType = AVMediaType.video
		let authorisationStatus=AVCaptureDevice.authorizationStatus(for: mediaType)
        
        switch authorisationStatus {
        case .authorized:
            completion(true)
        case .notDetermined:
            
			AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { (granted) in
                completion(granted)
            })
            
        case .denied:
            
            let alert=UIAlertController(title: localisedString(string: "cameraaccess_alerttitle"), message: localisedString(string: "cameraaccessdenied_alertmessage"), preferredStyle: .alert)
            
            let cancelAction=UIAlertAction(title: localisedString(string: UIStrings.CANCEL), style: .default, handler: nil)
            alert.addAction(cancelAction)
            
            let settingsAction=UIAlertAction(title: localisedString(string: UIStrings.SETTINGS), style: .default, handler: { (action) in
				UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            })
            alert.addAction(settingsAction)
            
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            
            
        case .restricted:
            
            let alert=UIAlertController(title: localisedString(string: "cameraaccess_alerttitle"), message: localisedString(string: "cameraaccessrestricted_alertmessage"), preferredStyle: .alert)
            
            let cancelAction=UIAlertAction(title: localisedString(string: UIStrings.OK), style: .default, handler: nil)
            alert.addAction(cancelAction)
            
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        
        
        }
        
    }
    
    
    
    
    /// checks and returns if the user can access their photo library, will invoke authorisation
    /// if not currently authorised or prompt user to allow access if previously denied
    ///
    /// - Parameter completion: allowed: you can access the photo library
    class func requestPhotoLibraryAuthorization(completion:@escaping (_ allowed:Bool)->Void){
        
       let authorisationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorisationStatus {
        case .authorized:
            completion(true)
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization({ (status) in
                completion(status == .authorized)
            })
            
        case .denied:
            
            let alert=UIAlertController(title: localisedString(string: "photoaccess_alerttitle"), message: localisedString(string: "photoaccessdenied_alertmessage"), preferredStyle: .alert)
            
            let cancelAction=UIAlertAction(title: localisedString(string: UIStrings.CANCEL), style: .default, handler: nil)
            alert.addAction(cancelAction)
            
            let settingsAction=UIAlertAction(title: localisedString(string: UIStrings.SETTINGS), style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            })
            alert.addAction(settingsAction)
            
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            
            
        case .restricted:
            
            let alert=UIAlertController(title: localisedString(string: "photoaccess_alerttitle"), message: localisedString(string: "photoaccessrestricted_alertmessage"), preferredStyle: .alert)
            
            let cancelAction=UIAlertAction(title: localisedString(string: UIStrings.OK), style: .default, handler: nil)
            alert.addAction(cancelAction)
            
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            
            
        }
    
    
    }


        
}
