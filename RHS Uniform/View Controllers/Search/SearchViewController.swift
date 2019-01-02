//
//  SearchViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 05/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

protocol SearchViewControllerDelegate {
    
    func searchButton(show: Bool)
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate {

    var managedObjectContext: NSManagedObjectContext!
    var delegate: SearchViewControllerDelegate?
    
    var searchString = "" {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //delegate?.searchButton(show: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        searchBar.becomeFirstResponder()
    }
    
    deinit {
        //delegate?.searchButton(show: true)
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableViewCell", for: indexPath) as! ItemsTableViewCell
        
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
        let nameSortDescriptor = NSSortDescriptor(key: "itemName", ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        
        let namePredicate = NSPredicate(format: "itemName CONTAINS[c] %@", searchString)
        let descriptionPredicate = NSPredicate(format: "itemDescription CONTAINS[c] %@", searchString)
        let genderPredicate = NSPredicate(format: "itemGender CONTAINS[c] %@", searchString)
        let colorPredicate = NSPredicate(format: "itemColor CONTAINS[c] %@", searchString)
        
        let categoryPredicate = NSPredicate(format: "category.categoryName CONTAINS[c] %@", searchString)
        let yearPredicate = NSPredicate(format: "ANY years.yearName CONTAINS[c] %@", searchString)
        let sizePredicate = NSPredicate(format: "ANY sizes.#size.sizeName CONTAINS[c] %@", searchString)
        
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [namePredicate, descriptionPredicate, genderPredicate, colorPredicate, categoryPredicate, yearPredicate, sizePredicate])
        fetchRequest.predicate = predicate
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
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
            let cell = tableView.cellForRow(at: indexPath!)! as! ItemsTableViewCell
            configureCell(cell, withItem: anObject as! SUShopItem)
        case .move:
            let cell = tableView.cellForRow(at: indexPath!)! as! ItemsTableViewCell
            configureCell(cell, withItem: anObject as! SUShopItem)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showItem" {
            
            let itemViewController = segue.destination as! ItemViewController
            itemViewController.managedObjectContext = managedObjectContext
            itemViewController.item = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
        }
    }
    
    // MARK: - Search Bar Delegate

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchString = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchString = ""
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.showsCancelButton = false
    }
}
