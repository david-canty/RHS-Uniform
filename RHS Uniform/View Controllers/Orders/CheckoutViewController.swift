//
//  CheckoutViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 19/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage
import Stripe

enum Carrier: String, CustomStringConvertible {
    
    case collectionOnly = "Collection Only"
    case royalMail = "Royal Mail"
    case courier = "Courier"
    
    var description: String {
        get {
            return self.rawValue
        }
    }
}

struct PostageMethod {
    var carrier: Carrier
    var cost: Double
}

protocol CheckoutDelegate {
    func getOrderAmount() -> Double
    func getOrderItems() -> [[String: Any]]
}

class CheckoutViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext!
    var delegate: CheckoutDelegate?
    //let paymentContext: STPPaymentContext
    var paymentInfoVC: PaymentInformationViewController!
    var postageMethod: PostageMethod = PostageMethod(carrier: .collectionOnly, cost: 0.0)
    var orderAmount = 0.0
    
//    required init?(coder aDecoder: NSCoder) {
//
//        let customerContext = STPCustomerContext(keyProvider: StripeClient.sharedInstance)
//        paymentContext = STPPaymentContext(customerContext: customerContext)
//
//        super.init(coder: aDecoder)
//
//        paymentContext.delegate = self
//        paymentContext.hostViewController = self
//    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        navigationController?.navigationBar.shadowImage = UIImage(named: "nav_shadow")
        
        guard let orderAmount = delegate?.getOrderAmount() else {
            fatalError("Failed to get order amount")
        }
        self.orderAmount = orderAmount
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
    }

    // MARK: - Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width , height: 40.0))
        let headerLabel = UILabel(frame: CGRect(x: 16.0, y: 8.0, width: tableView.frame.width - 32.0, height: 24.0))
        headerView.addSubview(headerLabel)
        
        headerLabel.textColor = UIColor(red: 62.0/255.0, green: 60.0/255.0, blue: 146.0/255.0, alpha: 1.0)
        headerLabel.font = UIFont(name: "Arial-BoldMT", size: 16.0)
        headerLabel.text = "Items"
        headerLabel.textAlignment = NSTextAlignment.left
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkoutTableViewCell", for: indexPath) as! CheckoutTableViewCell
        
        let bagItem = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withBagItem: bagItem, at: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: CheckoutTableViewCell, withBagItem bagItem: SUBagItem, at indexPath: IndexPath) {
        
        guard let item = bagItem.item else { return }
        guard let size = bagItem.size else { return }
        
        // Image
        let itemImages = item.images as! Set<SUImage>
        let firstImage = (itemImages.first { $0.sortOrder == 0 })
        let imageFilename = firstImage?.filename ?? "dummy.png"
        
        let imagesUrlString = AppConfig.sharedInstance.s3BucketUrlString()
        
        let imageUrl = URL(string: "\(imagesUrlString)/\(imageFilename)")!
        let placeholderImage = UIImage(named: "placeholder_64x64")!
        
        let filter = AspectScaledToFitSizeFilter(size: cell.itemImageView.frame.size)
        
        cell.itemImageView.af_setImage(withURL: imageUrl, placeholderImage: placeholderImage, filter: filter)
        
        // Name
        cell.itemNameLabel.text = item.itemName
        
        // Price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let formattedPrice = formatter.string(from: item.itemPrice as NSNumber)
        cell.itemPriceLabel.text = formattedPrice
        
        // Stock
        if let itemSize = SUItemSize.getObjectWithItemId(item.id!, sizeId: size.id!) {
            
            let stockLevel = Int(itemSize.stock)
            var stockLevelAttributedString: NSAttributedString
            
            switch stockLevel {
                
            case 0:
                let stockLevelAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.red]
                stockLevelAttributedString = NSMutableAttributedString(string:"Out of stock", attributes: stockLevelAttributes as! [NSAttributedString.Key: NSObject])
                
            case let level where level < lowStockLevel:
                let stockLevelAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.orange]
                stockLevelAttributedString = NSMutableAttributedString(string:"Low stock", attributes: stockLevelAttributes as! [NSAttributedString.Key: NSObject])
            default:
                let stockLevelAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor(red: 0.0/255.0, green: 150.0/255.0, blue: 75.0/255.0, alpha: 1.0)]
                stockLevelAttributedString = NSMutableAttributedString(string:"In stock", attributes: stockLevelAttributes as! [NSAttributedString.Key: NSObject])
            }
            cell.itemStockLabel.attributedText = stockLevelAttributedString
        }
        
        // Size
        cell.itemSizeLabel.text = "Size: \(size.sizeName!)"
        
        // Quantity
        cell.itemQtyLabel.text = "Qty: \(bagItem.quantity)"
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<SUBagItem> {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<SUBagItem> = SUBagItem.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key: "item.itemName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<SUBagItem>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!)! as! CheckoutTableViewCell
            configureCell(cell, withBagItem: anObject as! SUBagItem, at: indexPath!)
        case .move:
            let cell = tableView.cellForRow(at: indexPath!)! as! CheckoutTableViewCell
            configureCell(cell, withBagItem: anObject as! SUBagItem, at: indexPath!)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "orderSummary" {
            
            let orderSummaryController = segue.destination as! OrderSummaryViewController
            orderSummaryController.delegate = self
        }
        
        if segue.identifier == "paymentInformation" {
            
            paymentInfoVC = segue.destination as? PaymentInformationViewController
            paymentInfoVC.delegate = self
        }
        
        if segue.identifier == "paymentMethods" {
            
            let paymentMethodsController = segue.destination as! PaymentMethodsViewController
            paymentMethodsController.delegate = self
        }
    }

    // MARK: - Button Actions
    
    @IBAction func cancelTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension CheckoutViewController: OrderSummaryDelegate {
    
    func fetchOrderSummaryData() -> OrderSummary {
    
        var orderSummaryData = OrderSummary()
        
        let bagItems = bagItemsCountAndValue()
        orderSummaryData.itemCount = bagItems.count
        orderSummaryData.itemValue = bagItems.value
        
        orderSummaryData.postageMethod = postageMethod
        
        return orderSummaryData
    }
    
    func bagItemsCountAndValue() -> (count: Int, value: Double) {
        
        var itemsCount = 0
        var itemsValue = 0.0
        
        let fetchRequest: NSFetchRequest<SUBagItem> = SUBagItem.fetchRequest()
        
        do {
            
            let bagItems = try managedObjectContext.fetch(fetchRequest)
            
            for bagItem in bagItems {
                
                let bagItemValue = (bagItem.item?.itemPrice)! * Double(bagItem.quantity)
                itemsCount += Int(bagItem.quantity)
                itemsValue += bagItemValue
            }
            
        } catch {
            
            print("Error fetching bag items count and value: \(error)")
        }
        
        return (itemsCount, itemsValue)
    }
}

extension CheckoutViewController: PaymentInformationDelegate {
    
    func fetchPaymentInformation() {
        
        
    }
    
    func showPaymentMethods() {
    
        performSegue(withIdentifier: "paymentMethods", sender: self)
    }
    
    func placeOrder(withPaymentMethod paymentMethod: PaymentMethod) {
        
        switch paymentMethod {
            
        case .bacs, .schoolBill:
            
            placeOrder()
            
        default:
            
            completeCharge { chargeId, error in
                
                guard let chargeId = chargeId else {
                    
                    if let error = error {
                        print("Error completing charge: \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async {
                        self.paymentInfoVC.stopPlaceOrderActivityIndicator()
                        self.displayPaymentError()
                    }
                    
                    return
                }
                
                self.placeOrder(withChargeId: chargeId)
            }
        }
    }
    
    func completeCharge(completion: @escaping (String?, Error?) -> Void) {
        
        let decimalNumberHandler = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let roundedOrderAmount = NSDecimalNumber(value: orderAmount).rounding(accordingToBehavior: decimalNumberHandler)
        let roundedOrderAmountInCents = roundedOrderAmount.multiplying(byPowerOf10: 2)
        let orderAmountInCents = Int(truncating: roundedOrderAmountInCents)
        
        let currency = AppConfig.sharedInstance.stripeChargeCurrency()
        let description = AppConfig.sharedInstance.stripeChargeDescription()
        
        StripeClient.sharedInstance.completeCharge(withAmount: orderAmountInCents, currency: currency, description: description) { chargeId, error in
            
            completion(chargeId, error)
        }
    }
    
    func displayPaymentError() {
        
        let alertController = UIAlertController(title: "Payment Unsuccessful",
                                                message: "Your payment was unsuccessful. Please check your card details and try again.",
                                                preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true)
    }
    
    func placeOrder(withChargeId chargeId: String? = nil) {
        
        guard let orderItems = delegate?.getOrderItems() else {
            fatalError("Failed to get order items")
        }
        
        guard var paymentMethod = paymentInfoVC.paymentMethod?.getDescription() else {
            fatalError("Failed to get payment method")
        }
        
        if case .card? = paymentInfoVC.paymentMethod {
         
            if let cardLast4 = paymentInfoVC.cardLast4 {
                paymentMethod += " ending " + cardLast4
            }
        }
        
        APIClient.sharedInstance.createOrder(withOrderItems: orderItems, paymentMethod: paymentMethod, chargeId: chargeId) { (orderInfo, error) in
            
            if let error = error as NSError? {
                fatalError("Error creating order: \(error), \(error.userInfo)")
            }
            
            if let orderInfo = orderInfo {
                
                self.saveOrder(withOrderInfo: orderInfo)
                
                DispatchQueue.main.async {
                    self.paymentInfoVC.stopPlaceOrderActivityIndicator()
                }
                
                self.performSegue(withIdentifier: "orderConfirmation", sender: self)
            }
        }
    }
    
    func saveOrder(withOrderInfo orderInfo: [String: Any]) {
        
        // Get order data
        guard let customerData = orderInfo["customer"] as? [String: Any],
            let orderData = orderInfo["order"] as? [String: Any],
            let orderItemsData = orderInfo["orderItems"] as? [[String: Any]] else {
            fatalError("Failed to get order data")
        }

        guard let customerId = customerData["id"] as? String else {
            fatalError("Failed to customer id")
        }
        
        guard let customer = SUCustomer.getObjectWithId(UUID(uuidString: customerId)!) else {
            fatalError("Failed to get customer")
        }
        
        guard let id = orderData["id"] as? Int,
            let orderStatus = orderData["orderStatus"] as? String,
            let paymentMethod = orderData["paymentMethod"] as? String,
            let orderDateString = orderData["orderDate"] as? String,
            let timestampString = orderData["timestamp"] as? String else {
                fatalError("Failed to get order info")
        }
        
        let chargeId = orderData["chargeId"] as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        guard let orderDate = dateFormatter.date(from: orderDateString) else {
            fatalError("Failed to convert order date due to mismatched format")
        }

        guard let timestampDate = dateFormatter.date(from: timestampString) else {
            fatalError("Failed to convert order timestamp due to mismatched format")
        }
        
        // Create order
        let order = SUOrder(context: managedObjectContext)
        order.id = Int32(id)
        order.orderStatus = orderStatus
        order.paymentMethod = paymentMethod
        order.chargeId = chargeId
        order.orderDate = orderDate
        order.timestamp = timestampDate
        order.customer = customer
        
        // Create order items
        for orderItemData in orderItemsData {
            
            guard let idString = orderItemData["id"] as? String,
                let itemIdString = orderItemData["itemID"] as? String,
                let sizeIdString = orderItemData["sizeID"] as? String,
                let quantity = orderItemData["quantity"] as? Int else {
                  fatalError("Failed to get order item info")
            }
            
            guard let item = SUShopItem.getObjectWithId(UUID(uuidString: itemIdString)!) else {
                fatalError("Failed to get item for order")
            }
            
            guard let size = SUSize.getObjectWithId(UUID(uuidString: sizeIdString)!) else {
                fatalError("Failed to get size for order")
            }
            
            // Attributes
            let orderItem = SUOrderItem(context: managedObjectContext)
            orderItem.id = UUID(uuidString: idString)
            orderItem.quantity = Int32(quantity)
            
            // Relationships
            orderItem.order = order
            orderItem.item = item
            orderItem.size = size
        }
        
        // Save context
        do {
            try self.managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}

extension CheckoutViewController: PaymentMethodsDelegate {
    
    
}

//extension CheckoutViewController: STPPaymentContextDelegate {
//
//    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
//
//        //paymentInfoVC.paymentMethodDetailTextLabel.text = paymentContext.selectedPaymentMethod?.label
//        paymentInfoVC.placeOrderButton.isEnabled = paymentContext.selectedPaymentMethod != nil
//    }
//
//    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
//
//
//    }
//
//    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
//
//        switch status {
//        case .error:
//            //self.showError(error)
//            return
//        case .success:
//            //self.showReceipt()
//            return
//        case .userCancellation:
//            return
//        }
//    }
//
//    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
//
//
//    }
//
//}
