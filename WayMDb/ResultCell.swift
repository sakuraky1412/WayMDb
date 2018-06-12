//
//  ResultCell.swift
//  WayMDb
//
//  Created by Kuan-Chi Chen on 6/11/18.
//  Copyright © 2018 Kuan-Chi Chen. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblTitleName: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var starRating: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
