//
//  CustomSegue.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/19/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class CustomSegue: UIStoryboardSegue {
    
    override func perform() {
        let src = self.source
        let dst = self.destination
        src.navigationController?.pushViewController(dst, animated: true)
    }
    
}
