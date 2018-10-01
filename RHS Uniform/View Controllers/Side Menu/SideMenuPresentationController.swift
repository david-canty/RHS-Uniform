//
//  SideMenuPresentationController.swift
//  RHS Uniform
//
//  Created by David Canty on 10/01/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class SideMenuPresentationController: UIPresentationController {
    
    let chrome = UIView()
    let chromeColor = UIColor(white: 0.2, alpha: 0.2)
    
    override func presentationTransitionWillBegin() {
        
        guard let containerView = containerView else {
            
            print("Error retrieving container view for presentation transition")
            return
        }
        
        presentedViewController.view.layer.shadowOpacity = 0.8
        
        chrome.frame = containerView.bounds
        chrome.alpha = 0.0
        chrome.backgroundColor = chromeColor
        addChromeTapGesture()
        containerView.insertSubview(chrome, at: 0)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            
            self.chrome.alpha = 1.0
            
        }, completion: nil)
    }
    
    func addChromeTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chromeTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        chrome.addGestureRecognizer(tapGesture)
    }
    
    @objc func chromeTapped(_ sender: UITapGestureRecognizer) {
        
        let notificationCenter = NotificationCenter.default
        let notification = Notification(name: Notification.Name(rawValue: "sideMenuChromeTapped"))
        notificationCenter.post(notification)
    }
    
    override func dismissalTransitionWillBegin() {
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            
            self.chrome.alpha = 0.0
            
        }, completion: { context in
            
            self.chrome.removeFromSuperview()
        })
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        guard let containerView = containerView else {
            
            print("Error retrieving container view for presented view frame")
            return CGRect()
        }
        
        let containerViewBounds = containerView.bounds
        let frameWidth: CGFloat = containerViewBounds.width * 0.66
        
        let presentedViewXOrigin = containerViewBounds.origin.x
        
        return CGRect(x: presentedViewXOrigin, y: containerViewBounds.origin.y, width: frameWidth, height: containerViewBounds.height)
    }
    
    override func containerViewWillLayoutSubviews() {
        
        guard let containerView = containerView else {
            
            print("Error retrieving container view for presented view")
            return
        }
        
        chrome.frame = containerView.bounds
        
        guard let presentedView = presentedView else {
            
            print("Error retrieving presented view")
            return
        }
        presentedView.frame = frameOfPresentedViewInContainerView
    }
}
