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

class CheckoutViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        navigationController?.navigationBar.shadowImage = UIImage(named: "nav_shadow")
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
            
            let paymentInformationController = segue.destination as! PaymentInformationViewController
            paymentInformationController.delegate = self
        }
    }

    // MARK: - Button Actions
    
    @IBAction func cancelTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}

extension CheckoutViewController: OrderSummaryDelegate {
    
    func fetchOrderSummary() {
    
        
    }
}

extension CheckoutViewController: PaymentInformationDelegate {
    
    func fetchPaymentInformation() {
        
        
    }
}
