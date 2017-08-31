//
//  Flight.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/19/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import ObjectMapper

struct Flight: Mappable {
    var departureCity: String?
    var departureAirportCode: String?
    var departureDateTime: Date?
    var departureTerminal: String?
    var departureGate: String?
    var arrivalCity: String?
    var arrivalAirportCode: String?
    var arrivalDateTime: Date?
    var arrivalTerminal: String?
    var arrivalGate: String?
    var seat: String?
    var flightNumber: String?
    var flightId: String?
    var flightDuration: String?
    var boardingTime: String?
    var flightCost: String?
    var flightType: String?
    
    init?(map: Map) {
        // check if a required "name" property exists within the JSON.
        if map.JSON["departureCity"] == nil {
            return nil
        }
        
        if map.JSON["arrivalCity"] == nil {
            return nil
        }
        
        if map.JSON["flightId"] == nil {
            return nil
        }
    }
    
    // Mappable
    mutating func mapping(map: Map) {
        flightId <- map["flightId"]
        flightNumber <- map["flightNumber"]
        flightDuration <- map["flightDuration"]
        
        departureCity <- map["departureCity"]
        departureAirportCode <- map["departureAirportCode"]
        departureDateTime <- (map["departureDateTime"], DateTransform())
        departureTerminal <- map["departureTerminal"]
        departureGate <- map["departureGate"]
        
        arrivalCity <- map["arrivalCity"]
        arrivalAirportCode <- map["arrivalAirportCode"]
        arrivalDateTime <- (map["arrivalDateTime"], DateTransform())
        arrivalTerminal <- map["arrivalTerminal"]
        arrivalGate <- map["arrivalGate"]
        
        seat <- map["seat"]
        boardingTime <- map["boardingTime"]
        
        flightCost <- map["flightCost"]
        flightType <- map["serviceType"]
    }
}
