//
//  BagTableViewCell.swift
//  RHS Uniform
//
//  Created by David Canty on 25/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class BagTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemStockLabel: UILabel!
    
    @IBOutlet weak var sizeButton: UIButton!
    @IBOutlet weak var quantityButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
        
    }

}
