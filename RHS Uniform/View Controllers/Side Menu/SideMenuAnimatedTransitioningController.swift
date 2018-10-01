//
//  SideMenuAnimatedTransitioningController.swift
//  RHS Uniform
//
//  Created by David Canty on 10/01/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class SideMenuAnimatedTransitioningController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresenting: Bool
    let duration: TimeInterval = 0.4
    
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
        
        let finalFrameForPresented = transitionContext.finalFrame(for: presentedViewController)
        let containerView = transitionContext.containerView
        
        presentedViewController.view.frame = finalFrameForPresented.offsetBy(dx: -finalFrameForPresented.width, dy: 0)
        containerView.addSubview(presentedViewController.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut, animations: {
                        
                        presentedViewController.view.frame = finalFrameForPresented
                        
        }) { completed in
            
            transitionContext.completeTransition(completed)
        }
    }
    
    func animateDismissTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let presentedControllerView = transitionContext.view(forKey: .from) else {
            
            print("Error retrieving presented view from transition context")
            return
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext) / 2,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        
                        presentedControllerView.frame.origin.x -= presentedControllerView.frame.width
            
        }) { completed in
            
            transitionContext.completeTransition(completed)
        }
    }
    
}
