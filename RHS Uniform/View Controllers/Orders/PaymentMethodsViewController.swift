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
    
    let sectionHeaderNames = ["Methods", "Cards"]
    
    let nonStripeSources = [["text": "BACS transfer", "detail": "Pay full amount via BACS transfer"],
                            ["text": "Add to school bill", "detail": "Add full amount to next school bill"]]
    var stripeSources = [[String: Any]]()
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        getStripeSources()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super .viewWillAppear(animated)
        
        
    }
    
    func getStripeSources() {
        
        if let customerId = KeychainController.readItem(withAccountName: "StripeCustomerId") {
            
            StripeClient.sharedInstance.getCustomer(withId: customerId, completion: { (customer, error) in
                
                if let sources = customer?["sources"] as? [String: Any] {
                    
                    if let sourcesData = sources["data"] as? [[String: Any]] {
                        
                        self.stripeSources = sourcesData
                        
                        DispatchQueue.main.async {

                            self.tableView.reloadData()
                        }
                    }
                }
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
        
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? nonStripeSources.count : stripeSources.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width , height: 40.0))
        let headerLabel = UILabel(frame: CGRect(x: 16.0, y: 10.0, width: tableView.frame.width - 32.0, height: 24.0))
        headerView.addSubview(headerLabel)
        
        headerLabel.textColor = UIColor(red: 62.0/255.0, green: 60.0/255.0, blue: 146.0/255.0, alpha: 1.0)
        headerLabel.font = UIFont(name: "Arial-BoldMT", size: 16.0)
        headerLabel.text = sectionHeaderNames[section]
        headerLabel.textAlignment = NSTextAlignment.left
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.section == 0 ? 44.0 : 60.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell

        if indexPath.section == 0 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "nonStripeSourceTableViewCell", for: indexPath)
            
            cell.textLabel?.text = nonStripeSources[indexPath.row]["text"]
            cell.detailTextLabel?.text = nonStripeSources[indexPath.row]["detail"]
            
        } else {
            
            let stripeCell = tableView.dequeueReusableCell(withIdentifier: "stripeSourceTableViewCell", for: indexPath) as! StripeSourceTableViewCell
            
            let source = stripeSources[indexPath.row]
            
            let brand = source["brand"] as! String
            let last4 = source["last4"] as! String
            let expMonth = String(format: "%02d", source["exp_month"] as! Int)
            let expYear = String(source["exp_year"] as! Int)
            let name = source["name"] as? String
            
            stripeCell.cardEndingLabel.text = brand + " ****" + last4
            stripeCell.cardNameLabel.text = name ?? "-"
            stripeCell.cardExpiryLabel.text = "Expires " + expMonth + "/" + expYear
            
            cell = stripeCell
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
    
        
        StripeClient.sharedInstance.createCustomerSource(token.tokenId) { (result, error) in
            
            
        }
        
        self.navigationController?.popViewController(animated: true)
//        StripeClient.sharedInstance.completeCharge(with: token, amount: 999) { result in
//
//            switch result {
//
//            case .success:
//
//                completion(nil)
//
//                let alertController = UIAlertController(title: "Success",
//                                                        message: "Your payment was successful!",
//                                                        preferredStyle: .alert)
//
//                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
//                    self.navigationController?.popViewController(animated: true)
//                })
//                alertController.addAction(alertAction)
//
//                self.present(alertController, animated: true)
//
//            case .failure(let error):
//
//                completion(error)
//            }
//        }
    }
    
}
