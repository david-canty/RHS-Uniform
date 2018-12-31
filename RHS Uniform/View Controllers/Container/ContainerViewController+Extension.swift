//
//  ContainerViewController+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 01/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import MessageUI

extension ContainerViewController: BackButtonDelegate {
    
    func toggleBackButton() {
        
        let backButtonHiddenXCoord = -44.0
        let backButtonShownXCoord = 8.0
        
        let navigationCount = embeddedNavigationController.viewControllers.count
        
        if navigationCount > 1 {
            
            // Show back button
            UIView.animate(withDuration: 0.2, animations: {
                
                self.backButtonView.frame = CGRect(x: backButtonShownXCoord, y: 0.0, width: Double(self.backButtonView.frame.width), height: Double(self.backButtonView.frame.height))
            })
            
        } else {
            
            // Hide back button
            UIView.animate(withDuration: 0.2, animations: {
                
                self.backButtonView.frame = CGRect(x: backButtonHiddenXCoord, y: 0.0, width: Double(self.backButtonView.frame.width), height: Double(self.backButtonView.frame.height))
            })
        }
    }
}

extension ContainerViewController: SearchViewControllerDelegate {
    
    func searchButton(show: Bool) {
        
        searchButton.isHidden = !show
    }
}

extension ContainerViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let error = error as NSError? {
            
            print("Mail compose error: \(error), \(error.userInfo)")
            
        } else {
        
            switch result {
            case .cancelled:
                print("Mail compose cancelled")
            case .failed:
                print("Mail compose failed")
            case .saved:
                print("Mail compose saved")
            case .sent:
                print("Mail compose sent")
            }
        
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
