//
//  CheckoutTableViewCell.swift
//  RHS Uniform
//
//  Created by David Canty on 19/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class CheckoutTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemStockLabel: UILabel!
    @IBOutlet weak var itemSizeLabel: UILabel!
    @IBOutlet weak var itemQtyLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
        
    }

}
