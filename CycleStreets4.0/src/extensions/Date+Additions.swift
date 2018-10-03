//
//  Date+Additions.swift
//
//  Created by Neil Edwards on 22/03/2017.
//

import Foundation


enum DateFormatString:String{
    
    case dbFormat="yyyy-MM-dd HH:mm:ss" // unix
    case shortdbFormat="yyyy-MM-dd HH:mm"
    case shortFormat="dd/MM/yy" // 12/09/10
    case shortFormatUS="MM/dd/yy" // 09/12/10
    case humanFormat="EEEE, MMMM d" // Wednesday, August 12
    case usefulhumanFormat="EE, MMM d yyyy" // Sat, Dec 12 2011
    case shortHumanFormat="dd MMM YY" // 22 Aug 10
    case shortHumanFormatWithTime="dd MMM yyyy HH:mm" // 22 Aug 2010 12:45
    case fullDateFormat="EEEE, MMMM dd, yyyy" // Wednesday, October 12, 2010
    case monthDateFormat="MMMM yyyy" // April 2011
    case twitterRESTFormat="E MMM dd HH:mm:ss '+0000' yyyy"
    case timeOnlyFormat="HH:mm" // 12:45
    case UTCFormat="yyyy-MM-dd HH:mm:ss z"
    case UTCTimeFormat="yyyy-MM-dd'T'HH:mm:ss.SSSZ" // unix time zone
    case UTCShortTimeFormat="yyyy-MM-dd'T'HH:mm:s"
    
}

extension Date{
    
    
    static func stringFromDate(date:Date, format:String)->String{
        
        let formatter = DateFormatter.cached(format)
        
        let formattedDateString=formatter.string(from: date)
        
        return formattedDateString
        
    }
        
    
}


private var cachedFormatters = [String : DateFormatter]()

extension DateFormatter {
    
    static func cached(_ format: String) -> DateFormatter {
        
        if let cachedFormatter = cachedFormatters[format] { return cachedFormatter }
        
        let formatter = DateFormatter()
        let localisedFormat = DateFormatter.dateFormat(fromTemplate: format, options: 0, locale: Locale.current)
        formatter.dateFormat = localisedFormat
        
        cachedFormatters[format] = formatter
        
        return formatter
    }
    
}
