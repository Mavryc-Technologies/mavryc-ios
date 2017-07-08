//
//  Date+Format.swift
//  mavryc
//
//  Created by Todd Hopkinson on 7/6/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

extension Date {
    
    public struct DateFormatStringsHelper {
        public struct DateFormatStrings {
            static let ddMMMMYYYY = "dd MMMM yyyy"
        }
    }
    
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Date.DateFormatStringsHelper.DateFormatStrings.ddMMMMYYYY
        return dateFormatter.string(from: self)
    }
    
    static func todayString() -> String {
        return Date().toString()
    }
}
