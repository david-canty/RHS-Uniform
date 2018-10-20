//
//  OrderSummaryViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 20/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class OrderSummaryViewController: UITableViewController {

    var numItems: Int = 0
    var itemsValue: Double = 0.0
    var postageType: String = ""
    var postageValue: Double = 0.0
    var orderTotal: Double = 0.0
    
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var itemsValueLabel: UILabel!
    @IBOutlet weak var postageLabel: UILabel!
    @IBOutlet weak var postageValueLabel: UILabel!
    @IBOutlet weak var orderTotalValueLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        updateOrderSummaryLabels()
    }

    func updateOrderSummaryLabels() {
        
        itemsLabel.text = "Items: " + String(numItems)

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let formattedItemsValue = formatter.string(from: itemsValue as NSNumber)
        itemsValueLabel.text = formattedItemsValue

        postageLabel.text = "Postage & Packing: " + postageType

        let formattedPostageValue = formatter.string(from: postageValue as NSNumber)
        postageValueLabel.text = formattedPostageValue

        let formattedTotalValue = formatter.string(from: orderTotal as NSNumber)
        orderTotalValueLabel.text = formattedTotalValue
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        
        header.textLabel?.textColor = UIColor(red: 62.0/255.0, green: 60.0/255.0, blue: 146.0/255.0, alpha: 1.0)
        header.textLabel?.font = UIFont(name: "Arial-BoldMT", size: 16.0)
        header.textLabel?.text = "Order Summary"
        header.textLabel?.textAlignment = NSTextAlignment.left
    }
    
}
