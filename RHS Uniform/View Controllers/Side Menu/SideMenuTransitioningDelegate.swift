//
//  SideMenuTransitioningDelegate.swift
//  RHS Uniform
//
//  Created by David Canty on 10/01/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class SideMenuTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return SideMenuPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return SideMenuAnimatedTransitioningController(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return SideMenuAnimatedTransitioningController(isPresenting: false)
    }
    
}
