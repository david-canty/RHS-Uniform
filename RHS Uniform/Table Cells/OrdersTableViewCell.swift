//
//  OrdersTableViewCell.swift
//  RHS Uniform
//
//  Created by David Canty on 11/11/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class OrdersTableViewCell: UITableViewCell {

    @IBOutlet weak var orderedLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

        
    }

}
