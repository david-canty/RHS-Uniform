//
//  OrderFilterViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 14/11/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import CoreData

protocol OrderFilterViewControllerDelegate {
    
    func getFilterStrings() -> [String]
    func orderFilterUpdatedWith(filter: String)
}

class OrderFilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var managedObjectContext: NSManagedObjectContext!
    var delegate: OrderFilterViewControllerDelegate!
    let notificationCenter = NotificationCenter.default
    
    var filterStrings = [String]()
    var selectedFilterString = ""
    var selectedRow = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        filterStrings = delegate.getFilterStrings()
        
        notificationCenter.addObserver(self, selector: #selector(chromeTapped(_:)), name:NSNotification.Name(rawValue: "orderFilterChromeTapped"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        selectedRow = filterStrings.index(of: selectedFilterString)!
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filterStrings.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 38.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Order Status"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let headerView = view as! UITableViewHeaderFooterView
        let tableViewWidth = tableView.frame.size.width
        
        let topSeparatorView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableViewWidth, height: 2.0))
        topSeparatorView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        headerView.addSubview(topSeparatorView)
        
        headerView.contentView.backgroundColor = UIColor.white
        headerView.textLabel?.font = UIFont(name: "Arial-BoldMT", size: 12.0)
        headerView.textLabel?.textColor = UIColor.black
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 38.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderFilterRadioTableViewCell", for: indexPath) as! OrderFilterRadioTableViewCell
        
        cell.titleLabel.text = filterStrings[indexPath.row]
        cell.button.isSelected = selectedRow == indexPath.row
            
        let cellButton = cell.button as! TaggedTableButton
        cellButton.addTarget(self, action: #selector(OrderFilterViewController.cellRadioButtonTapped(_:)), for: .touchUpInside)
        cellButton.sectionTag = indexPath.section
        cellButton.rowTag = indexPath.row
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        setRadioCellButtonStateAt(indexPath: indexPath)
    }
    
    func setRadioCellButtonStateAt(indexPath: IndexPath) {
        
        let oldCell = tableView.cellForRow(at: IndexPath(row: selectedRow, section: indexPath.section)) as! OrderFilterRadioTableViewCell
        oldCell.button.isSelected = false
        
        let cell = tableView.cellForRow(at: indexPath) as! OrderFilterRadioTableViewCell
        cell.button.isSelected = true
        
        selectedRow = indexPath.row
        selectedFilterString = filterStrings[selectedRow]
        delegate.orderFilterUpdatedWith(filter: selectedFilterString)
    }
    
    // MARK: - Button Actions
    
    @objc func cellRadioButtonTapped(_ sender: TaggedTableButton) {
        
        let tappedButtonSection = sender.sectionTag!
        let tappedButtonRow = sender.rowTag!
        let tappedButtonIndexPath = IndexPath(row: tappedButtonRow, section: tappedButtonSection)
        
        setRadioCellButtonStateAt(indexPath: tappedButtonIndexPath)
    }
    
    @IBAction func chromeTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}
