//
//  OrderItemCancelReturnTransitioningDelegate.swift
//  RHS Uniform
//
//  Created by David Canty on 02/01/2019.
//  Copyright © 2019 ddijitall. All rights reserved.
//

import UIKit

class OrderItemCancelReturnTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return OrderItemCancelReturnPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return OrderItemCancelReturnAnimatedTransitioningController(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return OrderItemCancelReturnAnimatedTransitioningController(isPresenting: false)
    }
}

