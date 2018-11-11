//
//  Storyboard+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 05/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    static func containerViewController() -> ContainerViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "ContainerViewController") as? ContainerViewController
    }
    
    static func signInViewController() -> SignInViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
    }
    
    static func sideMenuViewController() -> SideMenuViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SideMenuViewController") as? SideMenuViewController
    }
    
    static func modalSelectViewController() -> ModalSelectViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "ModalSelectViewController") as? ModalSelectViewController
    }
    
    static func bagViewController() -> BagViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "BagViewController") as? BagViewController
    }
    
    static func settingsViewController() -> SettingsViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
    }
    
    static func searchViewController() -> SearchViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
    }
    
    static func itemFilterViewController() -> ItemFilterViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "ItemFilterViewController") as? ItemFilterViewController
    }
    
    static func yourAccountViewController() -> YourAccountViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "YourAccountViewController") as? YourAccountViewController
    }
    
    static func ordersViewController() -> OrdersViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "OrdersViewController") as? OrdersViewController
    }
}
