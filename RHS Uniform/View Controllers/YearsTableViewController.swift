//
//  YearsTableViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 24/09/2017.
//  Copyright © 2017 ddijitall. All rights reserved.
//

import UIKit
import CoreData

protocol YearsDelegate {
    func toggleBackButton()
}

class YearsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext!
    var delegate: YearsDelegate?
    
    @IBOutlet weak var headerLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        headerLabel.text = "Uniform Shop"
        delegate?.toggleBackButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        delegate?.toggleBackButton()
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
        
        return 38.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let tableViewFrameWidth = tableView.frame.size.width
        
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableViewFrameWidth, height: 38.0))
        headerView.backgroundColor = UIColor(red: 62.0/255.0, green: 60.0/255.0, blue: 146.0/255.0, alpha: 0.8)
        
        let headerLabel = UILabel(frame: CGRect(x: 8.0, y: 0.0, width: tableViewFrameWidth - 16.0, height: 38.0))
        headerLabel.backgroundColor = UIColor.clear
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont(name: "Arial-BoldMT", size: 14.0)
        headerLabel.textAlignment = .left
        let sectionInfo = fetchedResultsController.sections![section]
        headerLabel.text = sectionInfo.name
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 38.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "yearsTableViewCell", for: indexPath) as! YearsTableViewCell
        
        let year = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withYear: year)
        
        return cell
    }
    
    func configureCell(_ cell: YearsTableViewCell, withYear year: UniformYear) {
        
        cell.yearLabel.text = year.yearName
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<UniformYear> {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<UniformYear> = UniformYear.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        let categorySortDescriptor = NSSortDescriptor(key: "school.schoolName", ascending: true)
        let nameSortDescriptor = NSSortDescriptor(key: "yearName", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [categorySortDescriptor, nameSortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "school.schoolName", cacheName: "")
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
    
    var _fetchedResultsController: NSFetchedResultsController<UniformYear>? = nil
    
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
            if let cell = tableView.cellForRow(at: IndexPath(row: (indexPath?.row)!, section: (indexPath?.section)!)) as? YearsTableViewCell {
                
                configureCell(cell, withYear: anObject as! UniformYear)
            }
        case .move:
            let cell = tableView.cellForRow(at: indexPath!)! as! YearsTableViewCell
            configureCell(cell, withYear: anObject as! UniformYear)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showItems" {
            
            let itemsViewController = segue.destination as! ItemsTableViewController
            itemsViewController.managedObjectContext = managedObjectContext
            
            let selectedYear = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
            itemsViewController.yearNameFilterStrings = [selectedYear.yearName!]
        }
    }

}
