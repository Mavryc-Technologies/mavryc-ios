//
//  ContactTableViewCell.swift
//  mavryc
//
//  Created by Todd Hopkinson on 7/25/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        self.title.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            self.backgroundColor = AppStyle.skylarDeepBlue
            self.title.textColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.clear
            self.title.textColor = UIColor.white
        }
    }
    
}
