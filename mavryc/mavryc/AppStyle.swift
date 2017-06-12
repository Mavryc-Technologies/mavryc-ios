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
    
    // MARK: - common styled button
    public static var styledButtonNormalTitleColor: UIColor = AppStyle.skylarGold
    public static var styledButtonDisabledTitleColor: UIColor = AppStyle.skylarBlueGrey
    public static var styledButtonHighlightedTextColor: UIColor = AppStyle.skylarGold
    public static var styledButtonBorderColor: UIColor = AppStyle.skylarBlueGrey.withAlphaComponent(0.5)
    public static var styledButtonBGColor: UIColor = AppStyle.skylarDeepBlue
    
    // MARK: - journey detail screen
    
    public static var journeyDetailsSegmentedControllerNormalTextColor: UIColor = skylarBlueGrey.withAlphaComponent(0.5)
    public static var journeyDetailsSegmentedControllerHighlightTextColor: UIColor = AppStyle.skylarGold
    public static var journeyDetailsSegmentedControllerBorderColor: UIColor = AppStyle.skylarBlueGrey.withAlphaComponent(0.5)
    
    
    // MARK: - Airport Search components
    public static var airportSearchTableViewSeparatorColor = AppStyle.skylarDeepBlue
    public static var airportSearchCellSelectionColor = AppStyle.skylarDeepBlue
    
    // MARK: - Aircraft Select Screen
    public static var aircraftSelectScreenCellHighlightColor = AppStyle.skylarGold
    public static var aircraftSelectScreenCellNormalColor = AppStyle.skylarDeepBlue
    public static var aircraftSelectScreenCellTextNormalColor = AppStyle.skylarBlueGrey
    public static var aircraftSelectScreenCellTextHighlightPrimaryColor = UIColor.white
    public static var aircraftSelectScreenCellTextHighlightSecondaryColor = AppStyle.skylarGold
}
