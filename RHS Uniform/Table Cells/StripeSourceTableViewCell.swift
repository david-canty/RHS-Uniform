//
//  StripeSourceTableViewCell.swift
//  RHS Uniform
//
//  Created by David Canty on 03/11/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class StripeSourceTableViewCell: UITableViewCell {

    @IBOutlet weak var cardEndingLabel: UILabel!
    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var cardExpiryLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

        
    }

}
