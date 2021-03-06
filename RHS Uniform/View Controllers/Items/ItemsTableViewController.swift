//
//  ItemsTableViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 28/09/2017.
//  Copyright © 2017 ddijitall. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

protocol BackButtonDelegate {
    func toggleBackButton()
}

class ItemsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext!
    var backButtonDelegate: BackButtonDelegate?
    let itemFilterTransitioningDelegate = ItemFilterTransitioningDelegate()
    let notificationCenter = NotificationCenter.default
    
    var genderFilterString = "All"
    var yearNameFilterStrings = [String]()
    var categoryNameFilterStrings = [String]()
    
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(apiUpdated(notification:)), name: NSNotification.Name(rawValue: "coreDataUpdatedFromAPI"), object: nil)
    }
    
    @objc func apiUpdated(notification: NSNotification) {
        
        UIView.transition(with: tableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: {
                            
                            self.tableView.reloadData()
                            
                            if self.fetchedResultsController.sections!.count == 0 {
                                
                                self.filterLabel.text = "No items are available"
                                self.filterButton.isHidden = true
                                
                            } else {
                                
                                self.setFilterLabelText()
                                self.setFilterButtonTitle()
                                self.filterButton.isHidden = false
                            }
        })
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        backButtonDelegate?.toggleBackButton()
        
        if fetchedResultsController.sections!.count == 0 {
            
            filterLabel.text = "No items are available"
            filterButton.isHidden = true
            
        } else {
            
            setFilterLabelText()
            setFilterButtonTitle()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        backButtonDelegate?.toggleBackButton()
    }
    
    func setFilterButtonTitle() {
        
        var filterCount = 0
        filterCount += genderFilterString != "All" ? 1 : 0
        filterCount += yearNameFilterStrings.count
        filterCount += categoryNameFilterStrings.count
        
        let filterButtonTitle = filterCount == 0 ? "Filter" : "Filter (\(filterCount))"
        filterButton.setTitle(filterButtonTitle, for: .normal)
    }
    
    func setFilterLabelText() {
        
        if fetchedResultsController.sections?.count == 0 {
            
            filterLabel.text = "No items match filter criteria"
            
        } else {
            
            let rowCount = fetchedResultsController.fetchedObjects!.count
            
            let itemsFetchRequest: NSFetchRequest<SUShopItem> = SUShopItem.fetchRequest()
            let itemCount = try! managedObjectContext.count(for: itemsFetchRequest)
            
            filterLabel.text = "Showing \(rowCount) of \(itemCount) items"
        }
    }
    
    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let tableViewFrameWidth = tableView.frame.size.width
        
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableViewFrameWidth, height: 30.0))
        headerView.backgroundColor = UIColor(red: 62.0/255.0, green: 60.0/255.0, blue: 146.0/255.0, alpha: 0.8)
        
        let headerLabel = UILabel(frame: CGRect(x: 16.0, y: 0.0, width: tableViewFrameWidth - 32.0, height: 30.0))
        headerLabel.backgroundColor = UIColor.clear
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont(name: "Arial-BoldMT", size: 14.0)
        headerLabel.textAlignment = .left
        let sectionInfo = fetchedResultsController.sections![section]
        let firstItem = sectionInfo.objects?.first as? SUShopItem
        headerLabel.text = firstItem?.category?.categoryName
        headerView.addSubview(headerLabel)

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemsTableViewCell", for: indexPath) as! ItemsTableViewCell

        let item = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withItem: item)

        return cell
    }
    
    func configureCell(_ cell: ItemsTableViewCell, withItem item: SUShopItem) {
        
        cell.itemNameLabel.text = item.itemName
        cell.itemGenderLabel.text = item.itemGender
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let formattedPrice = formatter.string(from: item.itemPrice as NSNumber)
        cell.itemPriceLabel.text = formattedPrice
        
        // Image
        let itemImages = item.images as! Set<SUImage>
        let firstImage = (itemImages.first { $0.sortOrder == 0 })
        let imageFilename = firstImage?.filename ?? "dummy.png"
        
        let imagesUrlString = AppConfig.shared.s3BucketUrlString()
        
        let imageUrl = URL(string: "\(imagesUrlString)/\(imageFilename)")!
        let placeholderImage = UIImage(named: "placeholder_64x64")!

        let filter = AspectScaledToFitSizeFilter(size: cell.itemImageView.frame.size)
        
        cell.itemImageView.af_setImage(withURL: imageUrl, placeholderImage: placeholderImage, filter: filter)
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<SUShopItem> {
        
        let fetchRequest: NSFetchRequest<SUShopItem> = SUShopItem.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        let categorySortDescriptor = NSSortDescriptor(key: "category.sortOrder", ascending: true)
        let nameSortDescriptor = NSSortDescriptor(key: "itemName", ascending: true)
        fetchRequest.sortDescriptors = [categorySortDescriptor, nameSortDescriptor]
        
        var predicateArray = [NSPredicate]()
        predicateArray.append(NSPredicate(format: "itemStatus == %@", ShopItemStatus.active.rawValue))
        
        if genderFilterString != "All" {
            
            predicateArray.append(NSPredicate(format: "itemGender == %@", genderFilterString))
        }
        
        if !yearNameFilterStrings.isEmpty {
            
            predicateArray.append(NSPredicate(format: "ANY years.yearName IN %@", yearNameFilterStrings))
        }
        
        if !categoryNameFilterStrings.isEmpty {
            
            predicateArray.append(NSPredicate(format: "category.categoryName IN %@", categoryNameFilterStrings))
        }

        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "category.sortOrder", cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<SUShopItem>? = nil
    
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
            if let cell = tableView.cellForRow(at: indexPath!) as? ItemsTableViewCell {
                configureCell(cell, withItem: anObject as! SUShopItem)
            } else {
                tableView.reloadRows(at: [indexPath!], with: .automatic)
            }
        case .move:
            let cell = tableView.cellForRow(at: indexPath!)! as! ItemsTableViewCell
            configureCell(cell, withItem: anObject as! SUShopItem)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        setFilterLabelText()
    }
    
    // MARK: - Filter
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        
        if let itemFilterVC = UIStoryboard.itemFilterViewController() {
            
            itemFilterVC.transitioningDelegate = itemFilterTransitioningDelegate
            itemFilterVC.modalPresentationStyle = .custom
            itemFilterVC.managedObjectContext = managedObjectContext
            itemFilterVC.delegate = self
            
            var filterStrings = [String: Any]()
            filterStrings["genderName"] = genderFilterString
            filterStrings["yearNames"] = yearNameFilterStrings
            filterStrings["categoryNames"] = categoryNameFilterStrings
            itemFilterVC.selectedFilterStrings = filterStrings
            
            present(itemFilterVC, animated: true, completion: nil)
        }
    }
    
    func emptyBag() {
        
        let fetchRequest: NSFetchRequest<SUBagItem> = SUBagItem.fetchRequest()
        fetchRequest.includesPropertyValues = false
        
        do {
            
            let bagItems = try managedObjectContext.fetch(fetchRequest)
            
            for item in bagItems {
                managedObjectContext.delete(item)
            }
            
            try managedObjectContext.save()
            
        } catch {
            
            let nserror = error as NSError
            print("Error deleting bag items: \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showItem" {
            
            let itemViewController = segue.destination as! ItemViewController
            itemViewController.managedObjectContext = managedObjectContext
            itemViewController.item = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
        }
    }

    @IBAction func unwindToShop(segue: UIStoryboardSegue) {
        
        emptyBag()
        
        let notificationCenter = NotificationCenter.default
        let notification = Notification(name: Notification.Name(rawValue: "bagUpdated"))
        notificationCenter.post(notification)
    }
}

extension ItemsTableViewController: ItemFilterViewControllerDelegate {
    
    func itemFilterUpdatedWith(filters: [String : Any]) {
        
        genderFilterString = filters["genderFilter"] as! String
        yearNameFilterStrings = filters["yearFilter"] as! [String]
        categoryNameFilterStrings = filters["categoryFilter"] as! [String]
        
        tableView.reloadData()
        setFilterButtonTitle()
        setFilterLabelText()
    }
}
