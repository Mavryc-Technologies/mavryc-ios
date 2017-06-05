//
//  PaxPicker.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/5/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

@IBDesignable class PaxPicker: UIView {
    
    @IBOutlet var view: UIView!
    
    var nibName: String = "PaxPicker"
    
    @IBOutlet weak var PaxCountLabel: UILabel!
    
    @IBOutlet weak var filledBarsImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    func setup() {
        view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth | UIViewAutoresizing.flexibleHeight
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: nibName, bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
}
