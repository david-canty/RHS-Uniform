//
//  PaymentMethodsViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 21/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import Stripe

enum PaymentMethod {
    case bacs
    case schoolBill
    case card(id: String)
    
    func getName() -> String {
        switch self {
        case .bacs:
            return "bacs"
        case .schoolBill:
            return "schoolBill"
        default:
            return "card"
        }
    }
    
    func getId() -> String {
        switch self {
        case .card(let id):
            return id
        default:
            return ""
        }
    }
}

protocol PaymentMethodsDelegate {
    
}

class PaymentMethodsViewController: UITableViewController {

    var delegate: PaymentMethodsDelegate?
    
    let sectionHeaderNames = ["Methods", "Cards"]
    
    let nonStripeSources = [["text": "BACS transfer", "detail": "Pay full amount via BACS transfer"],
                            ["text": "School bill", "detail": "Add full amount to next school bill"]]
    
    var stripeSources = [[String: Any]]()
    
    let bacsIndexPath: IndexPath
    let schoolBillIndexPath: IndexPath
    
    var selectedIndexPath: IndexPath
    var selectedPaymentMethod: PaymentMethod
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var addCardButton: UIButton!
    @IBOutlet weak var sourcesActivityIndicator: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        
        bacsIndexPath = IndexPath(row: 0, section: 0)
        schoolBillIndexPath = IndexPath(row: 1, section: 0)
        
        selectedIndexPath = bacsIndexPath
        selectedPaymentMethod = .bacs
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        addRightBarButtonItem()
        
        getStripeSources()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super .viewWillAppear(animated)
        
        guard let defaultPaymentMethod = userDefaults.dictionary(forKey: "defaultPaymentMethod") else {
            fatalError("Failed to load default payment method")
        }
        
        switch defaultPaymentMethod["name"] as! String {
        case "bacs":
            selectedPaymentMethod = .bacs
            selectedIndexPath = bacsIndexPath
            checkSelectedSource()
        case "schoolBill":
            selectedPaymentMethod = .schoolBill
            selectedIndexPath = schoolBillIndexPath
            checkSelectedSource()
        default:
            if let id = defaultPaymentMethod["id"] as? String {
                selectedPaymentMethod = .card(id: id)
            }
        }
    }
    
    func addRightBarButtonItem() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    func removeRightBarButtonItem() {
        
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func checkSelectedSource() {
        
        let selectedCell = tableView.cellForRow(at: selectedIndexPath)
        selectedCell?.accessoryType = .checkmark
    }
    
    func getStripeSources() {
        
        if let customerId = KeychainController.readItem(withAccountName: "StripeCustomerId") {
            
            addCardButton.isHidden = true
            removeRightBarButtonItem()
            sourcesActivityIndicator.startAnimating()
            
            StripeClient.sharedInstance.getCustomer(withId: customerId, completion: { (customer, error) in
                
                if let sources = customer?["sources"] as? [String: Any] {
                    
                    if let sourcesData = sources["data"] as? [[String: Any]] {
                        
                        self.stripeSources = sourcesData
                        
                        if case .card = self.selectedPaymentMethod {
                            
                            let defaultCardId = self.selectedPaymentMethod.getId()
                            
                            if let cardIndex = self.stripeSources.index(where: { $0["id"] as! String == defaultCardId }) {
                                
                                self.selectedIndexPath = IndexPath(row: cardIndex, section: 1)
                                
                            } else {
                                
                                self.selectedPaymentMethod = .bacs
                                self.selectedIndexPath = self.bacsIndexPath
                                self.saveDefaultPaymentMethod()
                            }
                        }
                        
                        DispatchQueue.main.async {

                            self.tableView.reloadData()
                            self.checkSelectedSource()
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    
                    self.addCardButton.isHidden = false
                    self.addRightBarButtonItem()
                    self.sourcesActivityIndicator.stopAnimating()
                }
            })
        }
    }

    @IBAction func addTapped(_ sender: Any) {
        
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let oldSelectedCell = tableView.cellForRow(at: selectedIndexPath)
        oldSelectedCell?.accessoryType = .none
        
        let newSelectedCell = tableView.cellForRow(at: indexPath)
        newSelectedCell?.accessoryType = .checkmark
        
        selectedIndexPath = indexPath
        
        switch selectedIndexPath {
        case bacsIndexPath:
            selectedPaymentMethod = .bacs
        case schoolBillIndexPath:
            selectedPaymentMethod = .schoolBill
        default:
            let cardId = stripeSources[indexPath.row]["id"] as! String
            selectedPaymentMethod = .card(id: cardId)
        }
        
        saveDefaultPaymentMethod()
    }
    
    func saveDefaultPaymentMethod() {
        
        let defaultPaymentMethod = ["name": selectedPaymentMethod.getName(),
                                    "id": selectedPaymentMethod.getId()]
        userDefaults.set(defaultPaymentMethod, forKey: "defaultPaymentMethod")
    }

}

extension PaymentMethodsViewController: STPAddCardViewControllerDelegate {
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        
        navigationController?.popViewController(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
    
        StripeClient.sharedInstance.createCustomerSource(token.tokenId) { (source, error) in
            
            if let error = error as NSError? {
                
                print("Error creating customer source: \(error.localizedDescription)")
                completion(error)
            }
            
            if let source = source as? [String: Any] {
                
                self.stripeSources.append(source)
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }
            
            completion(nil)
            
            self.navigationController?.popViewController(animated: true)
        }
        
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
