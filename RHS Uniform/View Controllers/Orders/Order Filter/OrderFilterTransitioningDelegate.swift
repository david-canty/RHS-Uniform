//
//  OrderFilterTransitioningDelegate.swift
//  RHS Uniform
//
//  Created by David Canty on 15/11/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class OrderFilterTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return OrderFilterPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return OrderFilterAnimatedTransitioningController(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return OrderFilterAnimatedTransitioningController(isPresenting: false)
    }
}
