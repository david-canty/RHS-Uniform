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
    func placeOrder(withPaymentMethod: PaymentMethod)
}

class PaymentInformationViewController: UITableViewController {

    var delegate: PaymentInformationDelegate?
    var paymentMethod: PaymentMethod?
    var cardLast4: String?
    
    @IBOutlet weak var paymentMethodDetailTextLabel: UILabel!
    @IBOutlet weak var paymentMethodActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var placeOrderButton: UIButton!
    @IBOutlet weak var placeOrderActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        delegate?.fetchPaymentInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        updatePaymentMethodLabel()
    }
    
    func updatePaymentMethodLabel() {
        
        paymentMethodDetailTextLabel.text = ""
        
        let userDefaults = UserDefaults.standard
        
        guard let defaultPaymentMethod = userDefaults.dictionary(forKey: "defaultPaymentMethod") else {
            fatalError("Failed to load default payment method")
        }
        
        switch defaultPaymentMethod["name"] as! String {
        case "bacs":
            paymentMethod = PaymentMethod.bacs
            paymentMethodDetailTextLabel.text = paymentMethod?.getDescription()
        case "schoolBill":
            paymentMethod = PaymentMethod.schoolBill
            paymentMethodDetailTextLabel.text = paymentMethod?.getDescription()
        default:
            if let cardId = defaultPaymentMethod["id"] as? String {
                paymentMethod = PaymentMethod.card(id: cardId)
                getCardDetailsWithId(cardId) { (details) in
                    self.paymentMethodDetailTextLabel.text = details
                }
            }
        }
    }
    
    func getCardDetailsWithId(_ cardId: String, completion: @escaping (String?) -> Void) {
        
        self.paymentMethodActivityIndicator.startAnimating()
        
        if let customerId = KeychainController.readItem(withAccountName: "StripeCustomerId") {
            
            StripeClient.shared.getCustomer(withId: customerId, completion: { (customer, error) in
                
                if let sources = customer?["sources"] as? [String: Any] {
                    
                    if let cards = sources["data"] as? [[String: Any]] {
                        
                        if let card = cards.first(where: { $0["id"] as! String == cardId }) {
                            
                            let brand = card["brand"] as! String
                            self.cardLast4 = card["last4"] as? String
                            
                            let cardDetails = brand + " ****" + self.cardLast4!
                            
                            completion(cardDetails)
                            
                        } else {
                        
                            completion(nil)
                        }
                        
                        self.paymentMethodActivityIndicator.stopAnimating()
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
        
        if let paymentMethod = self.paymentMethod {
            
            startPlaceOrderActivityIndicator()
            delegate?.placeOrder(withPaymentMethod: paymentMethod)
        }
    }
    
    func startPlaceOrderActivityIndicator() {
        placeOrderButton.isEnabled = false
        placeOrderActivityIndicator.startAnimating()
    }
    
    func stopPlaceOrderActivityIndicator() {
        placeOrderButton.isEnabled = true
        placeOrderActivityIndicator.stopAnimating()
    }
}
