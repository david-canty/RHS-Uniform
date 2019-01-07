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
    func orderItemCancelReturnDidFinish(withOrderItem orderItem: SUOrderItem, andAction action: SUOrderItemAction)
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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
            
            requestButton.isEnabled = true
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
        
        if let cancelReturnItem = cancelReturnItem,
            let orderItem = orderItem {
            
            requestButton.setTitle("", for: .normal)
            requestButton.isEnabled = false
            activityIndicator.startAnimating()
            
            APIClient.shared.cancelReturn(orderItemId: orderItem.id!, action: cancelReturnItem.rawValue, quantity: cancelReturnQuantity!) { orderItem, orderItemAction, error in
                
                if let error = error as NSError? {
                    
                    DispatchQueue.main.async {
                        
                        self.showAlert(title: "Error Amending Order", message: "The request to amend this order could not be completed: \(error.localizedDescription)")
                        
                        self.activityIndicator.stopAnimating()
                        self.setTitles()
                    }
                    
                } else {
                    
                    if let updatedOrderItem = orderItem,
                        let action = orderItemAction {
                        
                        DispatchQueue.main.async {
                            
                            self.activityIndicator.stopAnimating()
                            
                            self.delegate?.orderItemCancelReturnDidFinish(withOrderItem: updatedOrderItem, andAction: action)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func chromeTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}

extension OrderItemCancelReturnViewController {
    
    func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = UIColor(red: 203.0/255.0, green: 8.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
