//
//  PaymentInformationViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 20/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class PaymentInformationViewController: UITableViewController {

    @IBOutlet weak var paymentMethodDetailTextLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        updatePaymentMethodLabel()
    }
    
    func updatePaymentMethodLabel() {
        
        paymentMethodDetailTextLabel.text = "payment method"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        
        header.textLabel?.textColor = UIColor(red: 62.0/255.0, green: 60.0/255.0, blue: 146.0/255.0, alpha: 1.0)
        header.textLabel?.font = UIFont(name: "Arial-BoldMT", size: 16.0)
        header.textLabel?.text = "Payment Information"
        header.textLabel?.textAlignment = NSTextAlignment.left
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }

    // MARK: - Button Actions
    
    @IBAction func buyNowTapped(_ sender: UIButton) {
        
        print("Buy Now tapped")
    }
    
}
