//
//  StyledButton.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/7/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class StyledButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 12
        
        self.layer.borderColor = AppStyle.styledButtonBorderColor.cgColor
        self.layer.backgroundColor = AppStyle.styledButtonBGColor.cgColor
        
        self.setTitleColor(AppStyle.styledButtonNormalTitleColor, for: .normal)
        self.setTitleColor(AppStyle.styledButtonDisabledTitleColor, for: .disabled)
        self.setTitleColor(AppStyle.styledButtonHighlightedTextColor, for: .highlighted)
    }
}
