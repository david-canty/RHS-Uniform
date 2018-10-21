//
//  CheckoutViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 19/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import CoreData

class CheckoutViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        navigationController?.navigationBar.shadowImage = UIImage(named: "nav_shadow")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "orderSummary" {
            
            let orderSummaryController = segue.destination as! OrderSummaryViewController
            orderSummaryController.delegate = self
        }
        
        if segue.identifier == "paymentInformation" {
            
            let paymentInformationController = segue.destination as! PaymentInformationViewController
            paymentInformationController.delegate = self
        }
    }

    // MARK: - Button Actions
    
    @IBAction func cancelTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}

extension CheckoutViewController: OrderSummaryDelegate {
    
    func fetchOrderSummary() {
    
        
    }
}

extension CheckoutViewController: PaymentInformationDelegate {
    
    func fetchPaymentInformation() {
        
        
    }
}
