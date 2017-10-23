//
//  DeviceTableViewCell.swift
//  FeetForce
//
//  Created by JL on 20.10.17.
//  Copyright © 2017 JL. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    @IBOutlet var boardName: UILabel!
    @IBOutlet var boardDetail: UILabel!
    @IBOutlet var boardImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
