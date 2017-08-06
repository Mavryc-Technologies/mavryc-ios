//
//  AircraftSelectCell.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/7/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

//protocol AircraftSelectCellProtocol {
//    func aircraftSelectCell(cell: AircraftSelectCell, infoDetailsWasTapped: Bool)
//}

class AircraftSelectCell: UITableViewCell {

    @IBOutlet weak var lefthandView: UIView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var subtitle: UILabel!
    
    @IBOutlet weak var infoButtonImageView: UIImageView!
    
    @IBOutlet weak var infoButtonView: UIView!
    
    
    var unattributedTitle: String?
    
//    public var cellDelegate: AircraftSelectCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        if let infoButton = self.infoButtonView {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            infoButton.addGestureRecognizer(tap)
        }
    }
    
    func handleTap(gesture: UITapGestureRecognizer) -> Void {
        let cellTag = self.tag
        NotificationCenter.default.post(name: Notification.Name.SubscreenEvents.AircraftCellInfoButtonTap, object: self, userInfo:["tag":cellTag])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
