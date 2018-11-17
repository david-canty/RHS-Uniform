//
//  OrderDetailViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 16/11/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class OrderDetailViewController: UITableViewController {

    var order: SUOrder!
    var orderItems: [SUOrderItem]!
    
    let numberFormatter = NumberFormatter()
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var postageLabel: UILabel!
    @IBOutlet weak var orderDetailsTotal: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var paymentTotal: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        numberFormatter.numberStyle = .currency
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        displayOrderDetails()
        displayPaymentInformation()
    }
    
    func displayOrderDetails() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM yyyy"
        dateLabel.text = dateFormatter.string(from: order.orderDate!)
        
        statusLabel.text = order.orderStatus
        itemsLabel.text = String(getNumItems())
        
        let formattedPostage = numberFormatter.string(from: 0.0 as NSNumber)
        postageLabel.text = formattedPostage
        
        orderDetailsTotal.text = numberFormatter.string(from: getOrderTotal() as NSNumber)
    }
    
    func getNumItems() -> Int {
        
        return orderItems.reduce(0) { return $0 + Int($1.quantity) }
    }
    
    func getOrderTotal() -> Double {
        
        return orderItems.reduce(0.0, { (result, orderItem) -> Double in
            
            return result + ((orderItem.item!.itemPrice) * Double(orderItem.quantity))
        })
    }
    
    func displayPaymentInformation() {
        
        paymentMethodLabel.text = order.paymentMethod
        paymentTotal.text = numberFormatter.string(from: getOrderTotal() as NSNumber)
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderDetailTableViewCell", for: indexPath) as! OrderDetailTableViewCell

        let orderItem = orderItems[indexPath.row]
        
        cell.itemNameLabel.text = orderItem.item!.itemName
        cell.itemSizeLabel.text = "Size: " + orderItem.size!.sizeName!

        return cell
    }
    
    // MARK: - Button Actions
    
    

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
    }

}
