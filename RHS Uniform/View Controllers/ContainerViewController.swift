//
//  ContainerViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 24/09/2017.
//  Copyright © 2017 ddijitall. All rights reserved.
//

import UIKit
import CoreData

protocol ContainerViewControllerDelegate {
    
    func didSignOut()
}

class ContainerViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    var embeddedNavigationController: UINavigationController!
    var delegate: ContainerViewControllerDelegate?
    let sideMenuTransitioningDelegate = SideMenuTransitioningDelegate()
    let notificationCenter = NotificationCenter.default
    
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var bagButton: UIButton!
    @IBOutlet weak var bagBadge: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(bagUpdated(notification:)), name:NSNotification.Name(rawValue: "bagUpdated"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setBagBadge()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    @objc func bagUpdated(notification: NSNotification) {
        
        setBagBadge()
    }
    
    func setBagBadge() {
        
        do {
            
            let bagItemsFetchRequest: NSFetchRequest<SUBagItem> = SUBagItem.fetchRequest()
            var bagItems: [SUBagItem]
            bagItems = try managedObjectContext.fetch(bagItemsFetchRequest)
            
            if bagItems.count == 0 {
                
                bagBadge.text = ""
                bagBadge.isHidden = true
                bagButton.setImage(UIImage(named: "btn_bag"), for: .normal)
                
            } else {
                
                var bagItemsCount = 0
                
                for bagItem in bagItems {
                    
                    bagItemsCount += 1 * Int(bagItem.quantity)
                }
                
                bagBadge.text = String(bagItemsCount)
                bagBadge.isHidden = false
                bagButton.setImage(UIImage(named: "btn_bag_open"), for: .normal)
            }
            
        } catch {
            
            fatalError("Error fetching bag items: \(error)")
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }

    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showItems" {
            
            let embeddedItemsNavigationController = segue.destination as! UINavigationController
            embeddedNavigationController = embeddedItemsNavigationController
            
            let itemsViewController = embeddedNavigationController.topViewController as! ItemsTableViewController
            itemsViewController.backButtonDelegate = self
        }
    }

    // MARK: - Navigation Buttons
    
    @IBAction func titleButtonTapped(_ sender: UIButton) {
        
        embeddedNavigationController.popToRootViewController(animated: true)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        
        embeddedNavigationController.popViewController(animated: true)
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        
        showSideMenu()
    }
    
    @IBAction func menuSwipeRight(_ sender: UISwipeGestureRecognizer) {
        
        showSideMenu()
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        
        if embeddedNavigationController.topViewController is SearchViewController {
            
            embeddedNavigationController.popViewController(animated: true)
            return
        }
        
        let viewControllers: [UIViewController] = embeddedNavigationController.viewControllers
        for viewController in viewControllers {
            if viewController is SearchViewController {
                embeddedNavigationController.popToViewController(viewController, animated: true)
                return
            }
        }
            
        if let searchVC = UIStoryboard.searchViewController() {
            
            searchVC.managedObjectContext = managedObjectContext
            searchVC.delegate = self
            embeddedNavigationController.pushViewController(searchVC, animated: false)
        }
    }
    
    @IBAction func bagButtonTapped(_ sender: UIButton) {
        
        if !(embeddedNavigationController.visibleViewController is BagViewController) {
        
            showBag()
        }
    }
    
    // MARK: - Bag
    
    func showBag() {
        
        if let bagVC = UIStoryboard.bagViewController() {
            
            bagVC.managedObjectContext = self.managedObjectContext
            self.embeddedNavigationController.pushViewController(bagVC, animated: true)
        }
    }
    
    // MARK: - Side Menu
    
    func showSideMenu() {
        
        if let sideMenuVC = UIStoryboard.sideMenuViewController() {
        
            sideMenuVC.transitioningDelegate = sideMenuTransitioningDelegate
            sideMenuVC.modalPresentationStyle = .custom
            sideMenuVC.delegate = self
            
            show(sideMenuVC, sender: self)
        }
    }
    
    
}

// MARK: - Side Menu Delegate

extension ContainerViewController: SideMenuViewControllerDelegate {

    func sideMenuDidSelectItem(_ menuItem: String) {
        
        switch menuItem {
            
        case uniformShopLabel:
            showUniformShop()
        
        case yourOrdersLabel:
            showYourOrders()
            
        case yourAccountLabel:
            showYourAccount()
            
        case settingsLabel:
            showSettings()
            
        case contactLabel:
            showContact()
            
        case signOutLabel:
            signOut()
            
        default:
            return
        }
    }
    
    func showUniformShop() {
        
        embeddedNavigationController.popToRootViewController(animated: true)
    }
    
    func showYourOrders() {
        
        print("Your Orders tapped")
    }
    
    func showYourAccount() {
        
        let viewControllers: [UIViewController] = embeddedNavigationController.viewControllers
        for viewController in viewControllers {
            if viewController is YourAccountViewController {
                embeddedNavigationController.popToViewController(viewController, animated: true)
                return
            }
        }
        
        if let accountVC = UIStoryboard.yourAccountViewController() {
            
            embeddedNavigationController.pushViewController(accountVC, animated: true)
        }
    }
    
    func showSettings() {
        
        let viewControllers: [UIViewController] = embeddedNavigationController.viewControllers
        for viewController in viewControllers {
            if viewController is SettingsViewController {
                embeddedNavigationController.popToViewController(viewController, animated: true)
                return
            }
        }
        
        if let settingsVC = UIStoryboard.settingsViewController() {
            
            embeddedNavigationController.pushViewController(settingsVC, animated: true)
        }
    }
    
    func showContact() {
        
        print("Contact tapped")
    }
    
    func signOut() {
        
        delegate?.didSignOut()
    }
}
