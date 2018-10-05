//
//  ItemViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 17/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import AlamofireImage

enum ModalSelectMode {
    case none, size, qty
}

let lowStockLevel = 5

let availableQuantities = [["itemId": 1, "itemLabel": "1"],
                           ["itemId": 2, "itemLabel": "2"],
                           ["itemId": 3, "itemLabel": "3"],
                           ["itemId": 4, "itemLabel": "4"],
                           ["itemId": 5, "itemLabel": "5"],
                           ["itemId": 6, "itemLabel": "6"],
                           ["itemId": 7, "itemLabel": "7"],
                           ["itemId": 8, "itemLabel": "8"],
                           ["itemId": 9, "itemLabel": "9"],
                           ["itemId": 10, "itemLabel": "10"]]

class ItemViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext!
    var item: SUItem!
    let modalSelectTransitioningDelegate = ModalSelectTransitioningDelegate()
    var modalSelectMode: ModalSelectMode = .none
    let notificationCenter = NotificationCenter.default
    
    var availableSizes = [[String: Any]]()
    var selectedSize: [String: Any]!
    
    var stock: Int32 = 0
    
    var selectedQuantity: [String: Any]!
    
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemCategoryLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemGenderLabel: UILabel!
    @IBOutlet weak var itemColorLabel: UILabel!
    @IBOutlet weak var itemYearsLabel: UILabel!
    @IBOutlet weak var itemStockLabel: UILabel!
    @IBOutlet weak var sizeButton: UIButton!
    @IBOutlet weak var quantityButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        getSizes()
        selectedSize = availableSizes[0]
        
        selectedQuantity = availableQuantities[0]
        
        notificationCenter.addObserver(self, selector: #selector(apiUpdated(notification:)), name: NSNotification.Name(rawValue: "apiPollDidFinish"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        populateView()
    }

    func populateView() {
        
        getSizes()
        
        itemNameLabel.text = item.itemName
        itemCategoryLabel.text = item.category?.categoryName
        
//        let imagesUrlPath = AppConfig.sharedInstance.baseImagesUrlPath()
//        let url = URL(string: "\(imagesUrlPath)/\(String(describing: item.itemImage!))")!
//        let placeholderImage = UIImage(named: "placeholder_192x192")!
//        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
//            size: itemImageView.frame.size,
//            radius: 0.0
//        )
//        itemImageView.af_setImage(withURL: url, placeholderImage: placeholderImage, filter: filter)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let formattedPrice = formatter.string(from: item.itemPrice as NSNumber)
        itemPriceLabel.text = formattedPrice
        
        itemDescriptionLabel.text = item.itemDescription
        itemGenderLabel.text = item.itemGender
        itemColorLabel.text = item.itemColor
        
        var itemYearsString = ""
        if let itemYears = item.years?.allObjects as? [SUYear] {
            
            let sortedYears = itemYears
                .sorted { $0.school!.sortOrder < $1.school!.sortOrder }
                .sorted { $0.sortOrder < $1.sortOrder }
            
            var itemYearNames = [String]()
            for year in sortedYears {
                
                var yearName = year.yearName!
                if let yearRange = yearName.range(of: "Year") {
                    
                    yearName.removeSubrange(yearRange.lowerBound...yearRange.upperBound)
                }
                itemYearNames.append(yearName)
            }
            //itemYearNames = itemYearNames.sorted {$0.localizedStandardCompare($1) == .orderedAscending}
            itemYearsString = itemYearNames.joined(separator: ", ")
        }
        itemYearsLabel.text = itemYearsString
        
        updateStockLabel()
        
        for i in 0..<availableSizes.count {
            
            let availableSizeId = availableSizes[i]["itemId"] as! UUID
            if availableSizeId == selectedSize["itemId"] as! UUID {
                selectedSize["itemLabel"] = availableSizes[i]["itemLabel"]
                break
            }
        }
        sizeButton.setTitle("Size: \(String(describing: selectedSize["itemLabel"]!))", for: .normal)
        
        quantityButton.setTitle("Qty: \(String(describing: selectedQuantity["itemLabel"]!))", for: .normal)
    }
    
    func getSizes() {
        
        availableSizes.removeAll()
        
        let itemSizes = item.sizes?.allObjects as! [SUItemSize]
        let sortedSizes = itemSizes.sorted { $0.size!.sortOrder < $1.size!.sortOrder }
        
        for itemSize in sortedSizes {
            
            let sizeDict: [String: Any] = ["itemId": itemSize.size!.id!,
                                           "itemLabel": itemSize.size!.sizeName!]
            availableSizes.append(sizeDict)
        }
        //availableSizes = availableSizes.sorted {($0["itemLabel"] as! String).localizedStandardCompare($1["itemLabel"] as! String) == .orderedAscending}
    }
    
    func updateStockLabel() {
        
        if let itemSize = SUItemSize.getObjectWithItemId(item.id!, sizeId: selectedSize["itemId"] as! UUID) {
            
            stock = itemSize.stock
            
            let stockLabelAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial-BoldMT", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.black]
            let stockLabelAttributedString = NSMutableAttributedString(string: "Stock: ", attributes: stockLabelAttributes as! [NSAttributedString.Key: NSObject])
            
            var stockAttributedString: NSAttributedString
            
            switch stock {
                
            case 0:
                let stockAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.red]
                stockAttributedString = NSMutableAttributedString(string:"Out of stock", attributes: stockAttributes as! [NSAttributedString.Key: NSObject])
                
            case let level where level < lowStockLevel:
                let stockAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.orange]
                stockAttributedString = NSMutableAttributedString(string:"Low stock (\(stock))", attributes: stockAttributes as! [NSAttributedString.Key: NSObject])
            default:
                let stockAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor(red: 0.0/255.0, green: 150.0/255.0, blue: 75.0/255.0, alpha: 1.0)]
                stockAttributedString = NSMutableAttributedString(string:"In stock (\(stock))", attributes: stockAttributes as! [NSAttributedString.Key: NSObject])
            }
            stockLabelAttributedString.append(stockAttributedString)
            itemStockLabel.attributedText = stockLabelAttributedString
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func apiUpdated(notification: NSNotification) {
        
        do {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SUItem")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == %@", item.id! as CVarArg)
            let items = try managedObjectContext.fetch(fetchRequest) as! [SUItem]
            
            if items.count == 1 {
                
                item = items[0]
                self.populateView()
                
            } else if items.count == 0 {
                
                showItemUnavailableAlert()
            }
            
        } catch {
         
            fatalError("Error fetching item with id \(String(describing: item.id)): \(error)")
        }
    }
    
    func showItemUnavailableAlert() {
        
        let alertController = UIAlertController(title: "Item Unavailable", message: "This item is no longer available.", preferredStyle: .alert)
        alertController.view.tintColor = UIColor(red: 203.0/255.0, green: 8.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        
        let alertAction = UIAlertAction(title: "Close", style: .default) { (action) in
            
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Button Actions
    
    @IBAction func sizeButtonTapped(_ sender: Any) {
        
        if let modalSelectVC = UIStoryboard.modalSelectViewController() {
            
            modalSelectVC.transitioningDelegate = modalSelectTransitioningDelegate
            modalSelectVC.modalPresentationStyle = .custom
            modalSelectVC.delegate = self
            modalSelectVC.titleString = "Size"
            modalSelectVC.tableRowData = availableSizes
            
            var selectedSizeIndex = 0
            for i in 0..<availableSizes.count {
                
                let availableSizeId = availableSizes[i]["itemId"] as! UUID
                if availableSizeId == selectedSize["itemId"] as! UUID {
                    selectedSizeIndex = i
                    break
                }
            }
            modalSelectVC.selectedRow = selectedSizeIndex
            
            modalSelectMode = .size
            
            present(modalSelectVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func quantityTapped(_ sender: UIButton) {
        
        if let modalSelectVC = UIStoryboard.modalSelectViewController() {
            
            modalSelectVC.transitioningDelegate = modalSelectTransitioningDelegate
            modalSelectVC.modalPresentationStyle = .custom
            modalSelectVC.delegate = self
            modalSelectVC.titleString = "Quantity"
            modalSelectVC.tableRowData = availableQuantities
            modalSelectVC.selectedRow = (selectedQuantity["itemId"] as! Int) - 1
            modalSelectMode = .qty
            
            present(modalSelectVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func addToBagTapped(_ sender: UIButton) {
        
        prepareFeedback()
        
        let sizeId = selectedSize["itemId"] as! UUID
        let quantity = Int32(selectedQuantity["itemId"] as! Int)
        
        if let existingBagItem = SUBagItem.getObjectWithItemId(item.id!, sizeId: sizeId) {
                
            existingBagItem.quantity += quantity
            
        } else {
            
            let newBagItem = SUBagItem(context: managedObjectContext)
            newBagItem.id = UUID()
            newBagItem.quantity = quantity
            newBagItem.item = item
            newBagItem.size = SUSize.getObjectWithId(sizeId)
        }
        
        do {
            
            try managedObjectContext.save()
            
            let notificationCenter = NotificationCenter.default
            let notification = Notification(name: Notification.Name(rawValue: "bagUpdated"))
            notificationCenter.post(notification)
            
            triggerSuccessFeedback()
            
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: Modal Select Delegate

extension ItemViewController: ModalSelectViewControllerDelegate {
    
    func modalSelectDidSelect(item: [String : Any]) {
    
        if modalSelectMode == .size {
            
            selectedSize = item
            sizeButton.setTitle("Size: \(String(describing: selectedSize["itemLabel"]!))", for: .normal)
            
        } else if modalSelectMode == .qty {
            
            selectedQuantity = item
            quantityButton.setTitle("Qty: \(String(describing: selectedQuantity["itemLabel"]!))", for: .normal)
        }
        
        updateStockLabel()
        
//        if selectedQuantity["itemId"] as! Int > Int(stock) {
//            wobble(views: [itemStockLabel])
//        }
        
        modalSelectMode = .none
    }

}

extension ItemViewController {
    
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
