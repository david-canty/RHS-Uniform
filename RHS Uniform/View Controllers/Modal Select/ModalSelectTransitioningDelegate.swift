//
//  ModalSelectTransitioningDelegate.swift
//  RHS Uniform
//
//  Created by David Canty on 19/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class ModalSelectTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalSelectPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
         return ModalSelectAnimatedTransitioningController(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalSelectAnimatedTransitioningController(isPresenting: false)
    }
}
