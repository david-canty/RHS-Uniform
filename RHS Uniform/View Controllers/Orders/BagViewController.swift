//
//  BagViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 22/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

class BagViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext!
    let notificationCenter = NotificationCenter.default
    
    let modalSelectTransitioningDelegate = ModalSelectTransitioningDelegate()
    var modalSelectMode: ModalSelectMode = .none
    var rowForTappedQtyButton: Int?
    var rowForTappedSizeButton: Int?
    var availableSizes: [[String: Any]]?
    
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    @IBOutlet weak var tableHeaderLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let nib = UINib(nibName: "BagTableSectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "BagTableSectionHeader")
        
        notificationCenter.addObserver(self, selector: #selector(apiUpdated(notification:)), name: NSNotification.Name(rawValue: "apiPollDidFinish"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        updateTableHeaderLabel()
    }
    
    @objc func apiUpdated(notification: NSNotification) {
     
        updateTableHeaderLabel()
        tableView.reloadData()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    func updateTableHeaderLabel() {
        
        let bagCount = getBagCount()
        
        if bagCount > 0 {
            
            let headerLabelAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial-BoldMT", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.black]
            let itemString = bagCount == 1 ? "item" : "items"
            let bagString = "Bag (\(bagCount) \(itemString)): "
            
            let headerLabelAttributedString = NSMutableAttributedString(string: bagString, attributes: headerLabelAttributes as! [NSAttributedString.Key: NSObject])
            
            let bagValueAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.red]
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            let formattedPrice = formatter.string(from: getBagValue() as NSNumber)!
            
            let bagValueAttributedString = NSMutableAttributedString(string: formattedPrice, attributes: bagValueAttributes as! [NSAttributedString.Key: NSObject])

            headerLabelAttributedString.append(bagValueAttributedString)
            tableHeaderLabel.attributedText = headerLabelAttributedString
            
            tableHeaderLabel.isHidden = false
            
        } else {
            
            tableHeaderLabel.isHidden = true
        }
    }

    func getBagCount() -> Int {
        
        var bagCount = 0
        
        for bagItem in fetchedResultsController.fetchedObjects! {
            
            bagCount += Int(bagItem.quantity)
        }
        
        return bagCount
    }
    
    func getBagValue() -> Double {
        
        var bagValue = 0.0
        
        for bagItem in fetchedResultsController.fetchedObjects! {
            
            bagValue += (bagItem.item!.itemPrice) * Double(bagItem.quantity)
        }
        
        return bagValue
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "BagTableSectionHeader") as! BagTableSectionHeader
        
        if fetchedResultsController.fetchedObjects!.count > 0 {
            
            headerView.bagEmptyLabel.isHidden = true
            headerView.checkoutButton.isHidden = false
            headerView.checkoutButton.setTitle("Proceed to Checkout", for: .normal)
            headerView.delegate = self
            
        } else {
            
            headerView.checkoutButton.isHidden = true
            headerView.bagEmptyLabel.isHidden = false
            headerView.bagEmptyLabel.text = "Your bag is empty"
        }

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 118.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bagTableViewCell", for: indexPath) as! BagTableViewCell
        
        let bagItem = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withBagItem: bagItem, at: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: BagTableViewCell, withBagItem bagItem: SUBagItem, at indexPath: IndexPath) {
        
        guard let item = bagItem.item else { return }
        guard let size = bagItem.size else { return }
        
        // Image
        let itemImages = item.images as! Set<SUImage>
        let firstImage = (itemImages.first { $0.sortOrder == 0 })
        let imageFilename = firstImage?.filename ?? "dummy.png"
        
        let imagesUrlPath = AppConfig.sharedInstance.s3BucketUrlPath()
        
        let imageUrl = URL(string: "\(imagesUrlPath)/\(imageFilename)")!
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
        
        // Size button
        cell.sizeButton.addTarget(self, action: #selector(BagViewController.cellSizeButtonTapped(_:)), for: .touchUpInside)
        cell.sizeButton.tag = indexPath.row
        cell.sizeButton.setTitle("Size: \(size.sizeName!)", for: .normal)
        
        // Quantity button
        cell.quantityButton.addTarget(self, action: #selector(BagViewController.cellQtyButtonTapped(_:)), for: .touchUpInside)
        cell.quantityButton.tag = indexPath.row
        cell.quantityButton.setTitle("Qty: \(bagItem.quantity)", for: .normal)
        
        // Remove button
        cell.removeButton.addTarget(self, action: #selector(BagViewController.cellRemoveButtonTapped(_:)), for: .touchUpInside)
        cell.removeButton.tag = indexPath.row
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
            let cell = tableView.cellForRow(at: indexPath!)! as! BagTableViewCell
            configureCell(cell, withBagItem: anObject as! SUBagItem, at: indexPath!)
        case .move:
            let cell = tableView.cellForRow(at: indexPath!)! as! BagTableViewCell
            configureCell(cell, withBagItem: anObject as! SUBagItem, at: indexPath!)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
        
        let notificationCenter = NotificationCenter.default
        let notification = Notification(name: Notification.Name(rawValue: "bagUpdated"))
        notificationCenter.post(notification)
        
        updateTableHeaderLabel()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - Cell Button Actions
    
    @objc func cellSizeButtonTapped(_ sender: UIButton) {
        
        rowForTappedSizeButton = sender.tag
        let bagItem = fetchedResultsController.object(at: IndexPath(row: rowForTappedSizeButton!, section: 0))
        
        if let modalSelectVC = UIStoryboard.modalSelectViewController() {
            
            modalSelectVC.transitioningDelegate = modalSelectTransitioningDelegate
            modalSelectVC.modalPresentationStyle = .custom
            modalSelectVC.delegate = self
            modalSelectVC.titleString = "Size"
            
            getAvailableSizesFor(item: (bagItem.item)!)
            modalSelectVC.tableRowData = availableSizes!
            
            var selectedSizeIndex = 0
            for i in 0..<availableSizes!.count {
                
                let availableSizeId = availableSizes![i]["itemId"] as! UUID
                if availableSizeId == bagItem.size?.id {
                    selectedSizeIndex = i
                    break
                }
            }
            modalSelectVC.selectedRow = selectedSizeIndex
            
            modalSelectMode = .size
            
            present(modalSelectVC, animated: true, completion: nil)
        }
    }
    
    func getAvailableSizesFor(item: SUShopItem) {
        
        availableSizes = []
        
        if let itemSizes = item.sizes?.allObjects as? [SUItemSize] {
            
            let sortedSizes = itemSizes.sorted { $0.size!.sortOrder < $1.size!.sortOrder }
            
            for itemSize in sortedSizes {
                
                let sizeDict: [String: Any] = ["itemId": itemSize.size!.id!,
                                               "itemLabel": itemSize.size!.sizeName!]
                availableSizes!.append(sizeDict)
            }
        }
    }
    
    @objc func cellQtyButtonTapped(_ sender: UIButton) {
        
        rowForTappedQtyButton = sender.tag
        let bagItem = fetchedResultsController.object(at: IndexPath(row: rowForTappedQtyButton!, section: 0))
        
        if let modalSelectVC = UIStoryboard.modalSelectViewController() {
            
            modalSelectVC.transitioningDelegate = modalSelectTransitioningDelegate
            modalSelectVC.modalPresentationStyle = .custom
            modalSelectVC.delegate = self
            modalSelectVC.titleString = "Quantity"
            modalSelectVC.tableRowData = availableQuantities
            modalSelectVC.selectedRow = Int(bagItem.quantity) - 1
            modalSelectMode = .qty
            
            present(modalSelectVC, animated: true, completion: nil)
        }
    }
    
    @objc func cellRemoveButtonTapped(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Remove Item", message: "Are you sure you wish to remove this item from your bag?", preferredStyle: .alert)
        alertController.view.tintColor = UIColor(red: 203.0/255.0, green: 8.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (action) in
            
            let buttonTag = sender.tag
            
            let bagItem = self.fetchedResultsController.object(at: IndexPath(row: buttonTag, section: 0))
            self.managedObjectContext.delete(bagItem)
            
            self.saveContextAndUpdateUI()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(removeAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func saveContextAndUpdateUI() {
        
        do {
            
            try managedObjectContext.save()
            
            let notificationCenter = NotificationCenter.default
            let notification = Notification(name: Notification.Name(rawValue: "bagUpdated"))
            notificationCenter.post(notification)
            
            updateTableHeaderLabel()
            
            tableView.reloadData()
            
        } catch {
            
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showCheckout" {
            
            let navigationController = segue.destination as! UINavigationController
            let checkOutVC = navigationController.topViewController as! CheckoutViewController
            
            checkOutVC.managedObjectContext = managedObjectContext
        }
    }

}

extension BagViewController: BagTableSectionHeaderDelegate {
    
    func didTapCheckoutButton() {
        
        self.performSegue(withIdentifier: "showCheckout", sender: self)
    }
}

// MARK: Modal Select Delegate

extension BagViewController: ModalSelectViewControllerDelegate {
    
    func modalSelectDidSelect(item: [String : Any]) {
        
        if modalSelectMode == .size {
            
            let bagItem = fetchedResultsController.object(at: IndexPath(row: rowForTappedSizeButton!, section: 0))
            
            let sizeId = item["itemId"] as! UUID
            let size = SUSize.getObjectWithId(sizeId)
            bagItem.size = size
            
            saveContextAndUpdateUI()
            
            availableSizes = nil
            rowForTappedSizeButton = nil
            
        } else if modalSelectMode == .qty {
            
            let bagItem = fetchedResultsController.object(at: IndexPath(row: rowForTappedQtyButton!, section: 0))
            
            bagItem.quantity = Int32(item["itemId"] as! Int)
            saveContextAndUpdateUI()
            
            rowForTappedQtyButton = nil
        }
        
        modalSelectMode = .none
    }
}

extension BagViewController {
    
    func prepareFeedback() {
        
        feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator?.prepare()
    }
    
    func triggerSuccessFeedback() {
        
        feedbackGenerator?.notificationOccurred(.success)
        feedbackGenerator = nil
    }
    
    func triggerWarningFeedback() {
        
        feedbackGenerator?.notificationOccurred(.warning)
        feedbackGenerator = nil
    }
    
    func triggerErrorFeedback() {
        
        feedbackGenerator?.notificationOccurred(.error)
        feedbackGenerator = nil
    }
}
