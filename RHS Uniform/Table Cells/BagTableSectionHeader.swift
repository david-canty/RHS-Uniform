//
//  BagTableSectionHeader.swift
//  RHS Uniform
//
//  Created by David Canty on 28/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

protocol BagTableSectionHeaderDelegate: class {
    
    func didTapCheckoutButton()
}

class BagTableSectionHeader: UITableViewHeaderFooterView {
    
    weak var delegate: BagTableSectionHeaderDelegate?
    
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var bagEmptyLabel: UILabel!
    
    @IBAction func didTapCheckoutButton(_ sender: AnyObject) {
        
        delegate?.didTapCheckoutButton()
    }
    
}
