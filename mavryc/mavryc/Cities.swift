//
//  Cities.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/6/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class Cities {
    
    fileprivate var _cities = [String]()
    
    static let shared: Cities = {
                let instance = Cities()
                return instance
    }()
    
    init() {
        if let json = self.loadJson(fileName: "states-cities") {
            _cities = self.parseCities(json: json)
        }
        assert(_cities.count > 0, "failure to populate cities list")
    }
    
    private func loadJson(fileName: String) -> JSON? {
        guard let path : String = Bundle.main.path(forResource: fileName, ofType: "json") else { return nil }
        guard let data = NSData(contentsOfFile: path) else { return nil }
        return JSON(data: data as Data)
    }
    
    private func parseCities(json: JSON) -> [String] {
        var cityStateStrings = [String]()
        json.forEach { (state, cityJsons) in
            cityJsons.forEach({ (nodeKey, citiesJson) in
                if nodeKey == "cities" {
                    citiesJson.forEach({ (city, _) in
                        cityStateStrings.append("\(city), \(state)")
                    })
                }
            })
        }
        return cityStateStrings
    }
    
    /// list of strings formatted as "city, state", e.g. "Scottsdale, AZ"
    public var cities: [String] {
        get {
            return _cities
        }
    }
}

extension Cities: AutoCompletionPredictable {

    func autoCompletionSuggestions(for input:String, predictions:(([Any]) -> Void)?) {
        
        // NOTE: this function may potentially call to a service such as Google Places or something like it. For now, we will provide autocompletion suggestions based on local json list.
        
        var items = [String]()
        items = cities.filter { item in
            // TODO: replace naive implementation for more refined results and zip in airports and other business rules as determined.
            return item.lowercased().contains(input.lowercased())
        }
        predictions?(items)
    }
}
