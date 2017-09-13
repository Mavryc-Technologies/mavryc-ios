//
//  SlideoutMenuTableViewCell.swift
//  mavryc
//
//  Created by Todd Hopkinson on 8/10/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class SlideoutMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        self.title.textColor = UIColor.white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.backgroundColor = AppStyle.skylarBlueGrey
        } else {
            self.backgroundColor = AppStyle.skylarMidBlue
        }
    }
    
}
