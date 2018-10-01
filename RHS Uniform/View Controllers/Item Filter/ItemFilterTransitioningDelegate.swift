//
//  ItemFilterTransitioningDelegate.swift
//  RHS Uniform
//
//  Created by David Canty on 05/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class ItemFilterTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return ItemFilterPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return ItemFilterAnimatedTransitioningController(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return ItemFilterAnimatedTransitioningController(isPresenting: false)
    }
}
