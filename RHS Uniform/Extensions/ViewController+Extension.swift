//
//  ViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 22/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func wobble(views: [UIView]) {
        
        let wobble = CAKeyframeAnimation(keyPath:"transform")
        wobble.values = [NSValue(caTransform3D: CATransform3DMakeTranslation(-5.0, 0.0, 0.0)), NSValue(caTransform3D: CATransform3DMakeTranslation(5.0, 0.0, 0.0))]
        wobble.autoreverses = true
        wobble.repeatCount = 2.0
        wobble.duration = 0.10
        
        for view in views {
            
            view.layer.add(wobble, forKey: "transform")
        }
    }
}
