//
//  ContainerViewController+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 01/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

extension ContainerViewController: YearsDelegate {
    
    func toggleBackButton() {
        
        let navigationCount = embeddedNavigationController.viewControllers.count
        
        if navigationCount > 1 {
            
            // Show back button
            UIView.animate(withDuration: 0.3, animations: {
                
                self.backButtonView.frame = CGRect(x: self.backButtonShownXCoord, y: 11.0, width: Double(self.backButtonView.frame.width), height: Double(self.backButtonView.frame.height))
            })
            
        } else {
            
            // Hide back button
            UIView.animate(withDuration: 0.3, animations: {
                
                self.backButtonView.frame = CGRect(x: self.backButtonHiddenXCoord, y: 11.0, width: Double(self.backButtonView.frame.width), height: Double(self.backButtonView.frame.height))
            })
        }
    }
}

extension ContainerViewController: SearchViewControllerDelegate {
    
    func searchButton(show: Bool) {
        
        searchButton.isHidden = !show
    }
}
