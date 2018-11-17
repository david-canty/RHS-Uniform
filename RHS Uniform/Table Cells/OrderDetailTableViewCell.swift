//
//  OrderDetailTableViewCell.swift
//  RHS Uniform
//
//  Created by David Canty on 16/11/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class OrderDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemSizeLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var buyAgainButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

        
    }

}
