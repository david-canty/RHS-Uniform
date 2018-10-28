//
//  PaymentMethodsViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 21/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import Stripe

protocol PaymentMethodsDelegate {
    
}

class PaymentMethodsViewController: UITableViewController {

    var delegate: PaymentMethodsDelegate?
    var customer: STPCustomer?
    
    let nonStripePaymentMethods = ["BACS transfer", "Add to termly bill"]
    
    override func viewDidLoad() {

        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super .viewWillAppear(animated)
        
        if let customerId = KeychainController.readItem(withAccountName: "StripeCustomerId") {
            
            StripeClient.sharedInstance.getCustomer(withId: customerId, completion: { (customer, error) in
                
                
            })
        }
    }

    @objc func addTapped(_ sender: UIBarButtonItem) {
        
//        let paymentConfig = STPPaymentConfiguration()
//        paymentConfig.canDeletePaymentMethods = true
//        paymentConfig.requiredBillingAddressFields = STPBillingAddressFields.full
//
//        let addCardViewController = STPAddCardViewController(configuration: paymentConfig, theme: .default())
//        addCardViewController.prefilledInformation = STPUserInformation()
        
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        navigationController?.pushViewController(addCardViewController, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return nonStripePaymentMethods.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell

        if indexPath.section == 0 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "nonStripePaymentTableViewCell", for: indexPath)
            
            cell.textLabel?.text = nonStripePaymentMethods[indexPath.row]
            
        } else {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        }

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension PaymentMethodsViewController: STPAddCardViewControllerDelegate {
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        
        navigationController?.popViewController(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
    
        StripeClient.sharedInstance.completeCharge(with: token, amount: 999) { result in
            
            switch result {
            
            case .success:
                
                completion(nil)
                
                let alertController = UIAlertController(title: "Success",
                                                        message: "Your payment was successful!",
                                                        preferredStyle: .alert)
                
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                alertController.addAction(alertAction)
                
                self.present(alertController, animated: true)
            
            case .failure(let error):
                
                completion(error)
            }
        }
    }
    
}
