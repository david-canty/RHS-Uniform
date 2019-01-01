//
//  OrderItemCancelReturnViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 01/01/2019.
//  Copyright © 2019 ddijitall. All rights reserved.
//

import UIKit

protocol OrderItemCancelReturnRequest {
    func orderItemRequestDidFinish(withQuantity quantity: Int, ofType type: OrderItemRequestType)
}

enum OrderItemRequestType {
    case cancel, `return`
}

class OrderItemCancelReturnViewController: UIViewController {

    var orderItem: SUOrderItem?
    var delegate: OrderItemCancelReturnRequest?
    var orderItemRequestType: OrderItemRequestType?
    var selectedQuantity = 1
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemSizeLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    @IBOutlet weak var cancelReturnQuantityLabel: UILabel!
    
    @IBOutlet weak var requestButton: UIButton!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setTitle()
        
        
    }
    
    func setTitle() {
        
        if let requestType = orderItemRequestType {
            
            switch requestType {
                
            case .cancel:
                titleLabel.text = "Request Cancellation"
                
            case .return:
                titleLabel.text = "Request Return"
            }
        }
    }
    
    // MARK: Button Actions

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        
        print("Close tapped")
    }
    
    @IBAction func qtyStepperValueChanged(_ sender: UIStepper) {
        
        print("Qty changed to \(sender.value)")
    }
    
    @IBAction func requestButtonTapped(_ sender: UIButton) {
        
        print("Request button tapped")
    }
}
