//
//  Airports.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/8/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import SQLite
import CoreLocation

class Airports {
    
    fileprivate var _airports = [AirportLocation]()
    
    static let shared: Airports = {
        let instance = Airports()
        return instance
    }()
    
    init() {
        if let json = self.loadJson(fileName: "states-cities") {
            _airports = self.parse(json: json)
        }
        assert(_airports.count > 0, "failure to populate cities list")
    }
    
    private func loadJson(fileName: String) -> JSON? {
        guard let path : String = Bundle.main.path(forResource: fileName, ofType: "json") else { return nil }
        guard let data = NSData(contentsOfFile: path) else { return nil }
        return JSON(data: data as Data)
    }
    
    private func parse(json: JSON) -> [AirportLocation] {
        var cityStateStrings = [AirportLocation]()
//        json.forEach { (state, cityJsons) in
//            cityJsons.forEach({ (nodeKey, citiesJson) in
//                if nodeKey == "cities" {
//                    citiesJson.forEach({ (city, _) in
//                        cityStateStrings.append("\(city), \(state)")
//                    })
//                }
//            })
//        }
        return cityStateStrings
    }

    /// list of strings formatted as "city, state", e.g. "Scottsdale, AZ"
//    public var airports: [AirportLocation] {
//        get {
//            return _airports
//        }
//    }
    
    public class func requestAirports(completion: (([AirportLocation]) -> Void)?) {
        
        let backgroundQueue = DispatchQueue(label: "com.mavryc.app.queue",
                                            qos: .background,
                                            target: nil)
        backgroundQueue.async {
            let path = Bundle.main.path(forResource: "airports", ofType: "sqlite3")!
            do {
                let db = try Connection(path, readonly: true)
                let airportsTable = Table("AirportTable")
                
                var aeroLocations = [AirportLocation]()
                
                let lat = Expression<String>("Latitude")
                let long = Expression<String>("Longitude")
                let name = Expression<String>("Name")
                let country = Expression<String>("Country")
                let city = Expression<String>("City")
                let code = Expression<String>("IATA")
                
                for aeroport in try db.prepare(airportsTable.where(country == "United States")) {
                    //print("aeroporte::: \(aeroport)")

                    let aLatitude = aeroport[lat]
                    let aLongitude = aeroport[long]
                    let aName = aeroport[name]
                    let aCity = aeroport[city]
                    let aCountry = aeroport[country]
                    let aCode = aeroport[code]
                    let loc = CLLocation(latitude: (aLatitude as NSString).doubleValue, longitude: (aLongitude as NSString).doubleValue)
                    let aeroLoc = AirportLocation(location: loc, code: aCode, name: aName, city: aCity, country: aCountry)
                    aeroLocations.append(aeroLoc)
                }
                
                completion?(aeroLocations)
                
            } catch {
                
            }
        }
    }
}

extension Airports: AutoCompletionPredictable {
    
    func autoCompletionSuggestions(for input:String, predictions:(([Any]) -> Void)?) {
        
        var items = [AirportLocation]()
//        items = airports.filter { item in
//            return item.lowercased().contains(input.lowercased())
//        }
        predictions?(items)
    }
}
