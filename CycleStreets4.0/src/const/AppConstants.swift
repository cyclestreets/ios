//
//  AppConstants.swift
//  CycleStreets4
//
//  Created by Neil Edwards on 03/10/2018.
//  Copyright © 2018 cyclestreets. All rights reserved.
//

import Foundation
import XCGLogger

let logger: XCGLogger = {
    
    let log = XCGLogger.default
    log.setup(level: .debug, showThreadName: false, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .debug)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm:ss.SSSS"
    dateFormatter.locale = NSLocale.current
    log.dateFormatter = dateFormatter
    
    return log
}()

struct UIStrings {
    
    static let OK:String = "OK"
    static let ABANDONED:String = "Abandoned"
    static let CLOSE:String = "Close"
    static let ERROR:String = "error"
    static let NONE:String = "none"
    static let NOTAVAILABLE:String = "N/A"
    static let LOADING:String = "loading"
    static let CANCEL:String = "Cancel"
    static let SPACE:String = " "
    static let RETURNCHAR:String = "/r"
    static let EMPTYSTRING:String = ""
    static let SETTINGS="SETTINGS"
}

enum Segues : String {
    case account
}

struct UserDefaultsConstants{
    
    static let AppVersion="AppVersion"
}
