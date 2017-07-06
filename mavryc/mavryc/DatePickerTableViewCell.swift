//
//  DatePickerTableViewCell.swift
//  mavryc
//
//  Created by Todd Hopkinson on 7/5/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class DatePickerTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.textLabel?.textColor = AppStyle.skylarBlueGrey
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        //self.backgroundColor = AppStyle.sk
        if selected {
            self.textLabel?.textColor = UIColor.white
        } else {
            self.textLabel?.textColor = AppStyle.skylarBlueGrey
        }
    }

}
