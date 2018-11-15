//
//  ItemFilterPresentationController.swift
//  RHS Uniform
//
//  Created by David Canty on 05/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class ItemFilterPresentationController: UIPresentationController {
    
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
        let notification = Notification(name: Notification.Name(rawValue: "itemFilterChromeTapped"))
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
        
        let containerViewController = presentingViewController as! ContainerViewController
        let itemsViewController = containerViewController.embeddedNavigationController.topViewController as! ItemsTableViewController
        let filterButton = itemsViewController.filterButton!
        let filterButtonConvertedFrame = filterButton.convert(filterButton.frame, to: UIScreen.main.coordinateSpace)
        
        let containerViewBounds = containerView.bounds
        
        let presentedViewXOrigin = containerViewBounds.width * 0.3
        let presentedViewYOrigin = filterButtonConvertedFrame.origin.y + filterButtonConvertedFrame.size.height
        
        let frameWidth: CGFloat = containerViewBounds.width - presentedViewXOrigin
        let frameHeight: CGFloat = containerViewBounds.height - presentedViewYOrigin
        
        return CGRect(x: presentedViewXOrigin, y: presentedViewYOrigin, width: frameWidth, height: frameHeight)
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
        
        let containerViewController = presentingViewController as! ContainerViewController
        let itemsViewController = containerViewController.embeddedNavigationController.topViewController as! ItemsTableViewController
        let filterButton = itemsViewController.filterButton!
        let filterButtonConvertedFrame = filterButton.convert(filterButton.frame, to: UIScreen.main.coordinateSpace)
        
        self.drawTriangle(size: 8.0, x: presentedView.frame.width - (filterButtonConvertedFrame.size.width), y: -7.0, up: true)
    }
    
    func drawTriangle(size: CGFloat, x: CGFloat, y: CGFloat, up: Bool) {
        
        let triangleLayer = CAShapeLayer()
        let trianglePath = UIBezierPath()
        trianglePath.move(to: .zero)
        trianglePath.addLine(to: CGPoint(x: -size, y: up ? size : -size))
        trianglePath.addLine(to: CGPoint(x: size, y: up ? size : -size))
        trianglePath.close()
        triangleLayer.path = trianglePath.cgPath
        triangleLayer.fillColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        triangleLayer.anchorPoint = .zero
        triangleLayer.position = CGPoint(x: x, y: y)
        triangleLayer.name = "triangle"
        presentedViewController.view.layer.addSublayer(triangleLayer)
    }
}
