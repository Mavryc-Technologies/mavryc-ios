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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        self.title.textColor = UIColor.darkGray
        self.backgroundColor = UIColor.white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.backgroundColor = UIColor.white
            self.title.textColor = AppStyle.skylarBlueGrey
        } else {
            self.backgroundColor = UIColor.white
            self.title.textColor = UIColor.darkGray
        }
    }
    
}
