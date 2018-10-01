//
//  ItemFilterViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 05/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import CoreData

protocol ItemFilterViewControllerDelegate {
    
    func itemFilterUpdatedWith(filters: [String: Any])
}

enum SectionType {
    case radio, check
}

class ItemFilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var managedObjectContext: NSManagedObjectContext!
    var delegate: ItemFilterViewControllerDelegate?
    
    var yearObjects = [UniformYear]()
    var categoryObjects = [UniformCategory]()
    
    var genderNames = [String]()
    var yearNames = [String]()
    var categoryNames = [String]()
    
    var expandedSectionHeaderNumber = -1
    
    var sectionNames = [String]()
    var sectionTypes = [SectionType]()
    var sectionItems = [[String]]()
    
    var selectedRows = [[Int]]()
    
    var selectedFilterStrings: [String: Any]?
    
    let notificationCenter = NotificationCenter.default
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearAllButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        sectionNames = ["Gender", "Year", "Category"]
        sectionTypes = [.radio, .check, .check]
        
        genderNames = ["All", "Boys", "Girls", "Unisex"]
        getYearObjectsAndNames()
        getCategoryObjectsAndNames()
        
        sectionItems = [genderNames, yearNames, categoryNames]
        
        for _ in sectionTypes {
            selectedRows.append([])
        }
        selectedRows[0] = [0]
        
        notificationCenter.addObserver(self, selector: #selector(chromeTapped(_:)), name:NSNotification.Name(rawValue: "itemFilterChromeTapped"), object: nil)
    }
    
    func getYearObjectsAndNames() {
        
        let fetchRequest: NSFetchRequest<UniformYear> = UniformYear.fetchRequest()
        
        let nameSortDescriptor = NSSortDescriptor(key: "yearName", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        
        do {
            
            yearObjects = try managedObjectContext.fetch(fetchRequest)
            
            for year in yearObjects {
                
                yearNames.append(year.yearName!)
            }
            
        } catch {
            
            let nserror = error as NSError
            fatalError("Error with years fetch request: \(nserror), \(nserror.userInfo)")
        }
    }
    
    func getCategoryObjectsAndNames() {
        
        let fetchRequest: NSFetchRequest<UniformCategory> = UniformCategory.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "categoryName", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        
        do {
            
            categoryObjects = try managedObjectContext.fetch(fetchRequest)
            
            for category in categoryObjects {
                
                categoryNames.append(category.categoryName!)
            }
            
        } catch {
            
            let nserror = error as NSError
            fatalError("Error with categories fetch request: \(nserror), \(nserror.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setupSelectedRows()
        displayClearAllButton()
    }
    
    func displayClearAllButton() {
        
        var selectedRowsIsEmpty = true
        
        for (i, _) in selectedRows.enumerated() {
            
            if sectionTypes[i] == .radio {
                
                if selectedRows[i][0] != 0 {
                    
                    selectedRowsIsEmpty = false
                }
                
            } else {
                
                if !selectedRows[i].isEmpty {
                    
                    selectedRowsIsEmpty = false
                }
            }
        }
        
        clearAllButton.isHidden = selectedRowsIsEmpty
    }
    
    func updateDelegate() {
        
        var filters = [String: Any]()
        
        let selectedGenderNameIndex = selectedRows[0][0]
        filters["genderFilter"] = genderNames[selectedGenderNameIndex]
        
        let selectedYears = selectedRows[1]
        var selectedYearNames = [String]()
        for yearIndex in selectedYears {
            
            selectedYearNames.append(yearNames[yearIndex])
        }
        filters["yearFilter"] = selectedYearNames
        
        let selectedCategories = selectedRows[2]
        var selectedCategoryNames = [String]()
        for categoryIndex in selectedCategories {
            
            selectedCategoryNames.append(categoryNames[categoryIndex])
        }
        filters["categoryFilter"] = selectedCategoryNames
        
        delegate?.itemFilterUpdatedWith(filters: filters)
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
        
        let chevronImageView = UIImageView(frame: CGRect(x: tableViewWidth - 16, y: 15, width: 8, height: 8));
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
