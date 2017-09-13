//
//  ConfirmDetailsViewModel.swift
//  mavryc
//
//  Created by Todd Hopkinson on 8/31/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

class ConfirmDetailsVeiwModelProvider {
    
    static let shared = ConfirmDetailsVeiwModelProvider()
    var confirmDetailsViewModel: ConfirmDetailsViewModel?
}

struct ConfirmDetailsViewModel {
    
    let jetserviceTypeString: String
    let tripTotalCost: String
    
    func trip() -> Trip? {
        return TripCoordinator.sharedInstance.currentTripInPlanning
    }
    
    func flights() -> [FlightInfo]? {
        return self.trip()?.flights
    }
    
    private func outboundDepartureFlightInfo() -> FlightInfo? {
        if let flights = self.flights() {
            return flights[0]
        }
        return nil
    }
    
    private func outboundArrivalFlightInfo() -> FlightInfo? {
        if let flights = self.flights() {
            return flights[0]
        }
        return nil
    }
    
    private func returnDepartureFlightInfo() -> FlightInfo? {
        if let flights = self.flights() {
            return flights[1]
        }
        return nil
    }
    
    private func returnArrivalFlightInfo() -> FlightInfo? {
        if let flights = self.flights() {
            return flights[1]
        }
        return nil
    }
    
    enum FlightSegment {
        case outboundDeparture
        case outboundArrival
        case returnDeparture
        case returnArrival
    }
    
    func city(of flightSegment: FlightSegment) -> String? {
        
        switch flightSegment {
        case .outboundDeparture:
            return outboundArrivalFlightInfo()?.departureString
        case .outboundArrival:
            return outboundArrivalFlightInfo()?.arrivalString
        case .returnDeparture:
            return returnDepartureFlightInfo()?.departureString
        case .returnArrival:
            return returnArrivalFlightInfo()?.arrivalString
        }
    }
    
    func airportCode(flightSegment: FlightSegment) -> String? {
        return self.threeLetterCodeFromCity(city: self.city(of: flightSegment))
    }
    
    // TODO: this implementation is temporary until the app/service layer provides real 3 letter codes for the airport
    private func threeLetterCodeFromCity(city: String?) -> String? {
        
        if let city = city {
            let start = city.startIndex
            let end = city.index(start, offsetBy: 3)
            let range = Range(uncheckedBounds: (lower: start, upper: end))
            var tresLetterCode = city[range]
            tresLetterCode = tresLetterCode.uppercased()
            return tresLetterCode
        }
        
        return "???"
    }
}
