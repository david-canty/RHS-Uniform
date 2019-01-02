//
//  OrderItemCancelReturnAnimatedTransitioningController.swift
//  RHS Uniform
//
//  Created by David Canty on 02/01/2019.
//  Copyright © 2019 ddijitall. All rights reserved.
//

import UIKit

class OrderItemCancelReturnAnimatedTransitioningController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresenting: Bool
    let duration: TimeInterval = 0.1
    
    init(isPresenting: Bool) {
        
        self.isPresenting = isPresenting
        
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if isPresenting {
            
            animatePresentTransition(transitionContext: transitionContext)
            
        } else {
            
            animateDismissTransition(transitionContext: transitionContext)
        }
    }
    
    func animatePresentTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let presentedViewController = transitionContext.viewController(forKey: .to) else {
            
            print("Error retrieving presented view controller from transition context")
            return
        }
        
        let containerView = transitionContext.containerView
        
        presentedViewController.view.alpha = 0.0
        containerView.addSubview(presentedViewController.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       options: .curveLinear,
                       animations: {
                        
                        presentedViewController.view.alpha = 1.0
                        
        }) { completed in
            
            transitionContext.completeTransition(completed)
        }
    }
    
    func animateDismissTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let presentedControllerView = transitionContext.view(forKey: .from) else {
            
            print("Error retrieving presented view from transition context")
            return
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       options: .curveLinear,
                       animations: {
                        
                        presentedControllerView.alpha = 0.0
                        
        }) { completed in
            
            transitionContext.completeTransition(completed)
        }
    }
    
}

