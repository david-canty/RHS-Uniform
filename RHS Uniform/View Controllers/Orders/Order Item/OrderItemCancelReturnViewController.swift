//
//  OrderItemCancelReturnViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 01/01/2019.
//  Copyright © 2019 ddijitall. All rights reserved.
//

import UIKit
import AlamofireImage

protocol OrderItemCancelReturnDelegate {
    func orderItemCancelReturnDidFinish(withQuantity quantity: Int, ofType type: CancelReturnItem)
}

enum CancelReturnItem: String {
    case cancelItem = "cancel"
    case returnItem = "return"
}

class OrderItemCancelReturnViewController: UIViewController {

    var orderItem: SUOrderItem?
    var delegate: OrderItemCancelReturnDelegate?
    let notificationCenter = NotificationCenter.default
    var cancelReturnItem: CancelReturnItem?
    var cancelReturnQuantity: Int?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemSizeLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    @IBOutlet weak var cancelReturnQuantityLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    @IBOutlet weak var requestButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(chromeTapped(_:)), name:NSNotification.Name(rawValue: "orderItemCancelReturnChromeTapped"), object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setTitles()
        setOrderItemData()
        setCancelReturnQuantityLabel()
    }
    
    func setTitles() {
        
        if let cancelReturn = cancelReturnItem {
            
            switch cancelReturn {
                
            case .cancelItem:
                
                titleLabel.text = "Cancel Item"
                requestButton.setTitle("Request Cancellation", for: .normal)
                
            case .returnItem:
                
                titleLabel.text = "Return Item"
                requestButton.setTitle("Request Return", for: .normal)
            }
        }
    }
    
    func setOrderItemData() {
        
        guard let orderItem = orderItem,
            let item = orderItem.item,
            let size = orderItem.size else { return }
            
        showImage(forItem: item)
        itemNameLabel.text = item.itemName
        itemSizeLabel.text = "Size: \(size.sizeName!)"
        itemQuantityLabel.text = "Qty ordered: \(orderItem.quantity)"
        cancelReturnQuantity = Int(orderItem.quantity)
        
        quantityStepper.maximumValue = Double(orderItem.quantity)
        quantityStepper.value = Double(orderItem.quantity)
        quantityStepper.isHidden = orderItem.quantity == 1
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let formattedPrice = formatter.string(from: item.itemPrice as NSNumber)
        itemPriceLabel.text = formattedPrice
    }
    
    func showImage(forItem item: SUShopItem) {
        
        let itemImages = item.images as! Set<SUImage>
        let image = (itemImages.first { $0.sortOrder == 0 })
        let imageFilename = image?.filename ?? "dummy.png"
        
        let imagesUrlString = AppConfig.shared.s3BucketUrlString()
        
        let imageUrl = URL(string: "\(imagesUrlString)/\(imageFilename)")!
        let placeholderImage = UIImage(named: "placeholder_64x64")!
        
        let filter = AspectScaledToFitSizeFilter(size: itemImageView.frame.size)
        
        itemImageView.af_setImage(withURL: imageUrl, placeholderImage: placeholderImage, filter: filter)
    }
    
    func setCancelReturnQuantityLabel() {
        
        if let cancelReturn = cancelReturnItem {
            
            cancelReturnQuantityLabel.text = "Qty to \(cancelReturn.rawValue): \(cancelReturnQuantity!)"
        }
    }
    
    // MARK: Button Actions

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func qtyStepperValueChanged(_ sender: UIStepper) {
        
        cancelReturnQuantity = Int(sender.value)
        setCancelReturnQuantityLabel()
    }
    
    @IBAction func requestButtonTapped(_ sender: UIButton) {
        
        if let cancelReturn = cancelReturnItem {
            
            delegate?.orderItemCancelReturnDidFinish(withQuantity: cancelReturnQuantity!, ofType: cancelReturn)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func chromeTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}
