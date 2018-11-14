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
    var delegate: OrderFilterViewControllerDelegate?
    let notificationCenter = NotificationCenter.default
    
    var filterStrings: [String]?
    var selectedRow: Int?
    var selectedFilterString: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        filterStrings = delegate?.getFilterStrings()
        selectedRow = 0
        selectedFilterString = filterStrings[selectedRow]
        
        notificationCenter.addObserver(self, selector: #selector(chromeTapped(_:)), name:NSNotification.Name(rawValue: "itemFilterChromeTapped"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
    }
    
    func updateDelegate() {
        
        delegate?.orderFilterUpdatedWith(filter: selectedFilterString)
    }
    
    func setupSelectedRows() {
        
        if selectedFilterStrings != nil {
            
            let genderFilterString = selectedFilterStrings!["genderName"] as! String
            selectedRows[0] = [genderNames.index(of: genderFilterString)!]
            
            let yearNameFilterStrings = selectedFilterStrings!["yearNames"] as! [String]
            for yearName in yearNameFilterStrings {
                
                selectedRows[1].append(yearNames.index(of: yearName)!)
            }
            
            let categoryNameFilterStrings = selectedFilterStrings!["categoryNames"] as! [String]
            for categoryName in categoryNameFilterStrings {
                
                selectedRows[2].append(categoryNames.index(of: categoryName)!)
            }
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sectionNames.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return expandedSectionHeaderNumber == section ? sectionItems[section].count : 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 38.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sectionNames[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let headerView = view as! UITableViewHeaderFooterView
        let tableViewWidth = tableView.frame.size.width
        
        let topSeparatorView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableViewWidth, height: 2.0))
        topSeparatorView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        headerView.addSubview(topSeparatorView)
        
        headerView.tag = section
        headerView.contentView.backgroundColor = UIColor.white
        headerView.textLabel?.font = UIFont(name: "Arial-BoldMT", size: 12.0)
        headerView.textLabel?.textColor = UIColor.black
        
        if let viewWithTag = self.view.viewWithTag(1000 + section) {
            viewWithTag.removeFromSuperview()
        }
        
        let chevronImageView = UIImageView(frame: CGRect(x: tableViewWidth - 32.0, y: 15.0, width: 8.0, height: 8.0));
        chevronImageView.image = UIImage(named: "img_down_chevron")
        chevronImageView.tag = 1000 + section
        headerView.addSubview(chevronImageView)
        
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(sectionHeaderWasTapped(_:)))
        headerView.addGestureRecognizer(headerTapGesture)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 38.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if sectionTypes[indexPath.section] == .radio {
            
            let radioCell = tableView.dequeueReusableCell(withIdentifier: "itemFilterRadioTableViewCell", for: indexPath) as! ItemFilterRadioTableViewCell
            
            radioCell.titleLabel.text = sectionItems[indexPath.section][indexPath.row]
            
            if selectedRows[indexPath.section].count == 1 {
                
                radioCell.button.isSelected = selectedRows[indexPath.section][0] == indexPath.row ? true : false
            }
            
            let radioCellButton = radioCell.button as! TaggedTableButton
            radioCellButton.addTarget(self, action: #selector(ItemFilterViewController.cellRadioButtonTapped(_:)), for: .touchUpInside)
            radioCellButton.sectionTag = indexPath.section
            radioCellButton.rowTag = indexPath.row
            
            cell = radioCell
            
        } else {
            
            let checkCell = tableView.dequeueReusableCell(withIdentifier: "itemFilterCheckTableViewCell", for: indexPath) as! ItemFilterCheckTableViewCell
            
            checkCell.titleLabel.text = sectionItems[indexPath.section][indexPath.row]
            
            checkCell.button.isSelected = false
            if selectedRows[indexPath.section].count > 0 {
                
                if selectedRows[indexPath.section].index(of: indexPath.row) != nil {
                    
                    checkCell.button.isSelected = true
                }
            }
            
            let checkCellButton = checkCell.button as! TaggedTableButton
            checkCellButton.addTarget(self, action: #selector(ItemFilterViewController.cellCheckButtonTapped(_:)), for: .touchUpInside)
            checkCellButton.sectionTag = indexPath.section
            checkCellButton.rowTag = indexPath.row
            
            cell = checkCell
        }
        
        return cell
    }
    
    @objc func sectionHeaderWasTapped(_ sender: UITapGestureRecognizer) {
        
        let headerView = sender.view as! UITableViewHeaderFooterView
        let sectionTag = headerView.tag
        let chevronImageView = headerView.viewWithTag(1000 + sectionTag) as? UIImageView
        
        if expandedSectionHeaderNumber == -1 {
            
            tableViewExpandSection(sectionTag, imageView: chevronImageView!)
            
        } else {
            
            if expandedSectionHeaderNumber == sectionTag {
                
                tableViewCollapeSection(sectionTag, imageView: chevronImageView!)
                
            } else {
                
                let expandedChevronImageView = self.view.viewWithTag(1000 + expandedSectionHeaderNumber) as? UIImageView
                
                tableViewCollapeSection(expandedSectionHeaderNumber, imageView: expandedChevronImageView!)
                
                tableViewExpandSection(sectionTag, imageView: chevronImageView!)
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
        })
        
        var indexPaths = [IndexPath]()
        for row in 0 ..< sectionItems[section].count {
            
            indexPaths.append(IndexPath(row: row, section: section))
        }
        
        expandedSectionHeaderNumber = -1
        
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPaths, with: UITableView.RowAnimation.fade)
        tableView.endUpdates()
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
        })
        
        var indexPaths = [IndexPath]()
        for row in 0 ..< sectionItems[section].count {
            
            indexPaths.append(IndexPath(row: row, section: section))
        }
        
        expandedSectionHeaderNumber = section
        
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.fade)
        tableView.endUpdates()
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if sectionTypes[indexPath.section] == .radio {
            
            setRadioCellButtonStateAt(indexPath: indexPath)
            
        } else {
            
            setCheckCellButtonStateAt(indexPath: indexPath)
        }
    }
    
    func setRadioCellButtonStateAt(indexPath: IndexPath) {
        
        if selectedRows[indexPath.section].count == 1 {
            
            let oldSelectedRowNumber = selectedRows[indexPath.section][0]
            let oldCell = tableView.cellForRow(at: IndexPath(row: oldSelectedRowNumber, section: indexPath.section)) as! ItemFilterRadioTableViewCell
            oldCell.button.isSelected = false
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! ItemFilterRadioTableViewCell
        cell.button.isSelected = true
        selectedRows[indexPath.section] = [indexPath.row]
        
        displayClearAllButton()
        updateDelegate()
    }
    
    func setCheckCellButtonStateAt(indexPath: IndexPath) {
        
        if selectedRows[indexPath.section].contains(indexPath.row) {
            
            let oldSelectedRowIndex = selectedRows[indexPath.section].index(of: indexPath.row)!
            let oldSelectedRowNumber = selectedRows[indexPath.section][oldSelectedRowIndex]
            
            let oldCell = tableView.cellForRow(at: IndexPath(row: oldSelectedRowNumber, section: indexPath.section)) as! ItemFilterCheckTableViewCell
            oldCell.button.isSelected = false
            
            selectedRows[indexPath.section].remove(at: oldSelectedRowIndex)
            
        } else {
            
            let cell = tableView.cellForRow(at: indexPath) as! ItemFilterCheckTableViewCell
            cell.button.isSelected = true
            selectedRows[indexPath.section].append(indexPath.row)
        }
        
        displayClearAllButton()
        updateDelegate()
    }
    
    // MARK: - Button Actions
    
    @objc func cellRadioButtonTapped(_ sender: TaggedTableButton) {
        
        let tappedButtonSection = sender.sectionTag!
        let tappedButtonRow = sender.rowTag!
        let tappedButtonIndexPath = IndexPath(row: tappedButtonRow, section: tappedButtonSection)
        
        setRadioCellButtonStateAt(indexPath: tappedButtonIndexPath)
    }
    
    @objc func cellCheckButtonTapped(_ sender: TaggedTableButton) {
        
        let tappedButtonSection = sender.sectionTag!
        let tappedButtonRow = sender.rowTag!
        let tappedButtonIndexPath = IndexPath(row: tappedButtonRow, section: tappedButtonSection)
        
        setCheckCellButtonStateAt(indexPath: tappedButtonIndexPath)
    }
    
    @IBAction func chromeTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearButtonTapped(_ sender:
        UIButton) {
        
        for (index, _) in selectedRows.enumerated() {
            
            if sectionTypes[index] == .radio {
                
                selectedRows[index] = [0]
                
            } else {
                
                selectedRows[index].removeAll()
            }
        }
        
        expandedSectionHeaderNumber = -1
        tableView.reloadData()
        displayClearAllButton()
        updateDelegate()
    }

}
