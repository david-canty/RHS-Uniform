//
//  OrderConfirmationViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 07/11/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class OrderConfirmationViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
}
