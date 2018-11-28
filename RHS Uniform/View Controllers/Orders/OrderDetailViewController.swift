//
//  OrderDetailViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 16/11/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

class OrderDetailViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext!
    var order: SUOrder!
    var orderItems: [SUOrderItem]!
    
    let numberFormatter = NumberFormatter()
    
    var rowForTappedCancelButton: Int?
    var rowForTappedBuyAgainButton: Int?
    var rowForTappedReturnButton: Int?
    
    @IBOutlet weak var orderNoLabel: UILabel!
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
        
        orderNoLabel.text = String(format: "%06d", order.id)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
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
        cell.itemQuantityLabel.text = "Qty: " + String(orderItem.quantity)
        
        let orderItemTotal = orderItem.item!.itemPrice * Double(orderItem.quantity)
        cell.itemPriceLabel.text = numberFormatter.string(from: orderItemTotal as NSNumber)
        
        // Image
        let itemImages = orderItem.item!.images as! Set<SUImage>
        let firstImage = (itemImages.first { $0.sortOrder == 0 })
        let imageFilename = firstImage?.filename ?? "dummy.png"
        
        let imagesUrlString = AppConfig.sharedInstance.s3BucketUrlString()
        
        let imageUrl = URL(string: "\(imagesUrlString)/\(imageFilename)")!
        let placeholderImage = UIImage(named: "placeholder_64x64")!
        
        let filter = AspectScaledToFitSizeFilter(size: cell.itemImageView.frame.size)
        
        cell.itemImageView.af_setImage(withURL: imageUrl, placeholderImage: placeholderImage, filter: filter)
        
        // Cancel button
        cell.cancelButton.addTarget(self, action: #selector(cellCancelButtonTapped(_:)), for: .touchUpInside)
        cell.cancelButton.tag = indexPath.row
        
        // Buy Again button
        cell.buyAgainButton.addTarget(self, action: #selector(cellBuyAgainButtonTapped(_:)), for: .touchUpInside)
        cell.buyAgainButton.tag = indexPath.row
        
        // Return button
        cell.returnButton.addTarget(self, action: #selector(cellReturnButtonTapped(_:)), for: .touchUpInside)
        cell.returnButton.tag = indexPath.row
        
        return cell
    }
    
    // MARK: - Button Actions
    
    @objc func cellCancelButtonTapped(_ sender: UIButton) {
        
        rowForTappedCancelButton = sender.tag
        
        print("Order item Cancel button tapped at row \(String(describing: rowForTappedCancelButton))")
    }
    
    @objc func cellBuyAgainButtonTapped(_ sender: UIButton) {
        
        rowForTappedBuyAgainButton = sender.tag
        performSegue(withIdentifier: "buyAgain", sender: self)
    }
    
    @objc func cellReturnButtonTapped(_ sender: UIButton) {
        
        rowForTappedReturnButton = sender.tag
        
        print("Order item Return button tapped at row \(String(describing: rowForTappedReturnButton))")
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "buyAgain" {
            
            let itemViewController = segue.destination as! ItemViewController
            
            itemViewController.managedObjectContext = managedObjectContext
            
            let orderItem = orderItems[rowForTappedBuyAgainButton!]
            itemViewController.item = orderItem.item
            itemViewController.preSelectedSizeId = orderItem.size!.id!
        }
    }

}
