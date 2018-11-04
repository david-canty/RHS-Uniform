//
//  PaymentInformationViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 20/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

protocol PaymentInformationDelegate {
    func fetchPaymentInformation()
    func showPaymentMethods()
    func placeOrder()
}

class PaymentInformationViewController: UITableViewController {

    var delegate: PaymentInformationDelegate?
    
    @IBOutlet weak var paymentMethodDetailTextLabel: UILabel!
    @IBOutlet weak var placeOrderButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        delegate?.fetchPaymentInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        updatePaymentMethodLabel()
    }
    
    func updatePaymentMethodLabel() {
        
        let userDefaults = UserDefaults.standard
        
        guard let defaultPaymentMethod = userDefaults.dictionary(forKey: "defaultPaymentMethod") else {
            fatalError("Failed to load default payment method")
        }
        
        switch defaultPaymentMethod["name"] as! String {
        case "bacs":
            paymentMethodDetailTextLabel.text = "BACS transfer"
        case "schoolBill":
            paymentMethodDetailTextLabel.text = "School bill"
        default:
            if let cardId = defaultPaymentMethod["id"] as? String {
                getCardDetailsWithId(cardId) { (details) in
                    self.paymentMethodDetailTextLabel.text = details
                }
            }
        }
    }
    
    func getCardDetailsWithId(_ cardId: String, completion: @escaping (String?) -> Void) {
        
        if let customerId = KeychainController.readItem(withAccountName: "StripeCustomerId") {
            
            StripeClient.sharedInstance.getCustomer(withId: customerId, completion: { (customer, error) in
                
                if let sources = customer?["sources"] as? [String: Any] {
                    
                    if let cards = sources["data"] as? [[String: Any]] {
                        
                        if let card = cards.first(where: { $0["id"] as! String == cardId }) {
                            
                            let brand = card["brand"] as! String
                            let last4 = card["last4"] as! String
                            
                            let cardDetails = brand + " ****" + last4
                            
                            completion(cardDetails)
                            
                        } else {
                        
                            completion(nil)
                        }
                    }
                }
            })
        }
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
        
        if indexPath.row == 0 {
            
            self.delegate?.showPaymentMethods()
        }
    }

    // MARK: - Button Actions
    
    @IBAction func placeOrderTapped(_ sender: UIButton) {
        
        delegate?.placeOrder()
    }
    
}
