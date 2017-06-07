//
//  AppStyle.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/3/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class AppStyle {
    
    class func setup() {
        SafeLog.print("AppStyle setup called")
        // add setup functions here as needed
    }
    
    // MARK: - Skylar Colors
    public static var skylarGold = #colorLiteral(red: 0.9882352941, green: 0.6470588235, blue: 0.1294117647, alpha: 1)
    public static var skylarDeepBlue = #colorLiteral(red: 0.05882352941, green: 0.07058823529, blue: 0.1058823529, alpha: 1)
    public static var skylarMidBlue = #colorLiteral(red: 0.05882352941, green: 0.1176470588, blue: 0.1764705882, alpha: 1)
    public static var skylarGrey = #colorLiteral(red: 0.1647058824, green: 0.2, blue: 0.2509803922, alpha: 1)
    public static var skylarBlueGrey = #colorLiteral(red: 0.3803921569, green: 0.4431372549, blue: 0.5333333333, alpha: 1)
    public static var skylarBlueGreen = #colorLiteral(red: 0.4274509804, green: 0.8235294118, blue: 0.8392156863, alpha: 1)
    
    // MARK: - journey detail screen
    public static var journeyDetailsNextButtonTextColor: UIColor = UIColor.white
    public static var journeyDetailsNextButtonSelectedTextColor: UIColor = AppStyle.skylarGold
    public static var journeyDetailsNextButtonBorderColor: UIColor = AppStyle.skylarBlueGrey.withAlphaComponent(0.5)
    public static var journeyDetailsNextButtonBGColor: UIColor = AppStyle.skylarDeepBlue
    
    public static var journeyDetailsSegmentedControllerNormalTextColor: UIColor = skylarBlueGrey.withAlphaComponent(0.5)
    public static var journeyDetailsSegmentedControllerHighlightTextColor: UIColor = AppStyle.skylarGold
    public static var journeyDetailsSegmentedControllerBorderColor: UIColor = AppStyle.skylarBlueGrey.withAlphaComponent(0.5)
    
    
    // MARK: - Airport Search components
    public static var airportSearchTableViewSeparatorColor = AppStyle.skylarDeepBlue
    public static var airportSearchCellSelectionColor = AppStyle.skylarDeepBlue
}
