//
//  ContainerViewController+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 01/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

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
