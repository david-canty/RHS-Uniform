//
//  ItemsTableViewCell.swift
//  RHS Uniform
//
//  Created by David Canty on 28/09/2017.
//  Copyright © 2017 ddijitall. All rights reserved.
//

import UIKit

class ItemsTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemGenderLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
