//
//  AutoCompletion.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/6/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

protocol AutoCompletionPredictable {
    
    /**
     Get a list of autocompletion suggestions based on input string
     
     - input: string to base returned autocompletion suggestions/predictions upon
     - predictions: list of auto-completion predictions
    */
    func autoCompletionSuggestions(for input:String, predictions:(([Any]) -> Void)?)
    
}
