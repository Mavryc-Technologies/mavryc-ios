//
//  GooglePlaces.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/22/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import GooglePlaces

class GooglePlacesClient: NSObject {
    static let sharedInstance = GooglePlacesClient()
    var completionHandler: (([Any]) -> Void)?
    var fetcher: GMSAutocompleteFetcher?
}

extension GooglePlacesClient: AutoCompletionPredictable {
    
    func autoCompletionSuggestions(for input:String, predictions:(([Any]) -> Void)?) {

        self.completionHandler = predictions
        
        // Set up the autocomplete filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        
        // Create the fetcher.
        self.fetcher = GMSAutocompleteFetcher(bounds: nil, filter: filter)
        self.fetcher?.delegate = self
        self.fetcher?.sourceTextHasChanged(input)
        
//        var items = [String]()
//  
//        let filter = GMSAutocompleteFilter()
//        filter.type = .establishment
//        GMSPlacesClient.shared().autocompleteQuery(input, bounds: nil, filter: filter, callback: {(results, error) -> Void in
//            if let error = error {
//                print("Autocomplete error \(error)")
//                return
//            }
//            if let results = results {
//                for result in results {
//                    //print("Result \(result.attributedFullText) with placeID \(result.placeID)")
//                    items.append(result.attributedFullText.string)
//                }
//            }
//        })
//        
//        predictions?(items)
    }
}

extension GooglePlacesClient: GMSAutocompleteFetcherDelegate {
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        //let resultsStr = NSMutableString()
        
        var items = [String]()
        for prediction in predictions {
            items.append(prediction.attributedFullText.string)
            //resultsStr.appendFormat("%@\n", prediction.attributedPrimaryText)
        }
        
        self.completionHandler?(items)
        
        //resultText?.text = resultsStr as String
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        print("\(error.localizedDescription)")
    }
    
}
