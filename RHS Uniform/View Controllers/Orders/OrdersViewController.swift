//
//  OrdersViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 11/11/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import CoreData

enum OrderStatus: String {
    case ordered = "Ordered"
    case awaitingStock = "Awaiting Stock"
    case readyForCollection = "Ready for Collection"
    case awaitingPayment = "Awaiting Payment"
    case complete = "Complete"
    case cancellationRequested = "Cancellation Requested"
    case cancelled = "Cancelled"
}

class OrdersViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext!
    let orderFilterTransitioningDelegate = OrderFilterTransitioningDelegate()
    let notificationCenter = NotificationCenter.default
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    
    let orderStatusFilterStrings = ["All",
                                    "Ordered",
                                    "Awaiting Stock",
                                    "Ready for Collection",
                                    "Awaiting Payment",
                                    "Complete"]
    var selectedOrderStatusFilter = "All"
    
    @IBOutlet weak var tableHeaderLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        dateFormatter.dateFormat = "d MMM yyyy"
        numberFormatter.numberStyle = .currency
        
        notificationCenter.addObserver(self, selector: #selector(apiUpdated(notification:)), name: NSNotification.Name(rawValue: "apiPollDidFinish"), object: nil)
    }
    
    @objc func apiUpdated(notification: NSNotification) {
        
        UIView.transition(with: tableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: {
                            
                            self.tableView.reloadData()
                            self.setFilterLabelText()
        })
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        tableHeaderLabel.text = "Your Orders"
        setFilterLabelText()
    }
    
    func setFilterLabelText() {
        
        let orderCount = fetchedResultsController.fetchedObjects?.count
        
        if orderCount == 0 && selectedOrderStatusFilter == "All" {
         
            filterLabel.text = "No orders"
            filterButton.isHidden = true
            
        } else if orderCount == 0 {
            
            filterLabel.text = "No orders: \(selectedOrderStatusFilter)"
            filterButton.isHidden = false
            
        } else {
            
            filterLabel.text = "Showing: \(selectedOrderStatusFilter)"
            filterButton.isHidden = false
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ordersTableViewCell", for: indexPath) as! OrdersTableViewCell
        
        let order = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withOrder: order)

        return cell
    }
    
    func configureCell(_ cell: OrdersTableViewCell, withOrder order: SUOrder) {
        
        // Ordered label
        let orderedLabelAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial-BoldMT", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        let orderedLabelAttributedString = NSMutableAttributedString(string: "Ordered: ", attributes: orderedLabelAttributes as! [NSAttributedString.Key: NSObject])
        
        var dateAttributedString: NSAttributedString
        let dateAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        let formattedDate = dateFormatter.string(from: order.orderDate!)
        dateAttributedString = NSMutableAttributedString(string: formattedDate, attributes: dateAttributes as! [NSAttributedString.Key: NSObject])
        orderedLabelAttributedString.append(dateAttributedString)
        cell.orderedLabel.attributedText = orderedLabelAttributedString
        
        // Status label
        let statusLabelAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial-BoldMT", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        let statusLabelAttributedString = NSMutableAttributedString(string: "Status: ", attributes: statusLabelAttributes as! [NSAttributedString.Key: NSObject])
        
        var statusAttributedString: NSAttributedString
        let statusAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        statusAttributedString = NSMutableAttributedString(string: order.orderStatus!, attributes: statusAttributes as! [NSAttributedString.Key: NSObject])
        statusLabelAttributedString.append(statusAttributedString)
        cell.statusLabel.attributedText = statusLabelAttributedString
        
        // Items count and total labels
        let (itemsCount, orderTotal) = getItemsCountAndTotal(for: order)
        cell.itemsLabel.text = String(itemsCount) + (itemsCount == 1 ? " item" : " items")
        let formattedTotal = numberFormatter.string(from: orderTotal as NSNumber)
        cell.totalLabel.text = formattedTotal
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<SUOrder> {
        
        let fetchRequest: NSFetchRequest<SUOrder> = SUOrder.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        let orderDateSortDescriptor = NSSortDescriptor(key: "orderDate", ascending: false)
        fetchRequest.sortDescriptors = [orderDateSortDescriptor]
        
        var orderStatusPredicate: NSPredicate?
        if selectedOrderStatusFilter != "All" {
            
            orderStatusPredicate = NSPredicate(format: "orderStatus == %@", selectedOrderStatusFilter)
        }
        fetchRequest.predicate = orderStatusPredicate
        
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
    
    var _fetchedResultsController: NSFetchedResultsController<SUOrder>? = nil
    
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
            if let cell = tableView.cellForRow(at: indexPath!) as? OrdersTableViewCell {
                configureCell(cell, withOrder: anObject as! SUOrder)
            } else {
                tableView.reloadRows(at: [indexPath!], with: .automatic)
            }
        case .move:
            let cell = tableView.cellForRow(at: indexPath!)! as! OrdersTableViewCell
            configureCell(cell, withOrder: anObject as! SUOrder)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        //setFilterLabelText()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let orderDetailVC = segue.destination as! OrderDetailViewController
        
        orderDetailVC.managedObjectContext = managedObjectContext
        
        let order = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
        orderDetailVC.order = order
        orderDetailVC.orderItems = order.orderItems?.allObjects as? [SUOrderItem]
    }

    // MARK: - Button Actions
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        
        if let orderFilterVC = UIStoryboard.orderFilterViewController() {
            
            orderFilterVC.transitioningDelegate = orderFilterTransitioningDelegate
            orderFilterVC.modalPresentationStyle = .custom
            orderFilterVC.delegate = self
            
            orderFilterVC.selectedFilterString = selectedOrderStatusFilter
            
            present(orderFilterVC, animated: true, completion: nil)
        }
    }
}

extension OrdersViewController {
    
    func getItemsCountAndTotal(for order: SUOrder) -> (itemsCount: Int, orderTotal: Double) {
        
        var itemsCount: Int = 0
        var orderTotal: Double = 0.0
        
        guard let orderItems = order.orderItems?.allObjects as? [SUOrderItem] else {
            return (itemsCount, orderTotal)
        }
        
        for orderItem in orderItems {
            
            itemsCount += Int(orderItem.quantity)
            orderTotal += orderItem.item!.itemPrice * Double(orderItem.quantity)
        }
        
        return (itemsCount, orderTotal)
    }
}

extension OrdersViewController: OrderFilterViewControllerDelegate {
    
    func getFilterStrings() -> [String] {
        
        return orderStatusFilterStrings
    }
    
    func orderFilterUpdatedWith(filter: String) {
        
        selectedOrderStatusFilter = filter
        tableView.reloadData()
        setFilterLabelText()
    }
    
}
