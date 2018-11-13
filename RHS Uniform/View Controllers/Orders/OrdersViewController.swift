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
}

class OrdersViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext!
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    var orderStatusFilterStrings = [String]()
    
    @IBOutlet weak var tableHeaderLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        dateFormatter.dateFormat = "d MMMM yyyy"
        numberFormatter.numberStyle = .currency
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        tableHeaderLabel.text = "Your Orders"
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
        
        cell.orderedLabel.text = "Ordered " + dateFormatter.string(from: order.orderDate!)
        cell.statusLabel.text = order.orderStatus
        
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
        if !orderStatusFilterStrings.isEmpty {
            
            orderStatusPredicate = NSPredicate(format: "orderStatus IN %@", orderStatusFilterStrings)
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
