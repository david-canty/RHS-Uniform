//
//  SideMenuViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 08/01/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

protocol SideMenuViewControllerDelegate {
    
    func sideMenuDidSelectItem(_ menuItem: String)
}

let uniformShopLabel = "Uniform Shop"
let yourOrdersLabel = "Your Orders"
let yourAccountLabel = "Your Account"
let settingsLabel = "Settings"
let contactLabel = "Contact"
let termsLabel = "Terms and Conditions"
let privacyLabel = "Privacy Policy"
let signOutLabel = "Sign Out"

class SideMenuViewController: UIViewController {

    var delegate: SideMenuViewControllerDelegate?
    let notificationCenter = NotificationCenter.default
    
    let tableRowLabels = [[uniformShopLabel, yourOrdersLabel, yourAccountLabel], [settingsLabel, contactLabel], [termsLabel, privacyLabel],  [signOutLabel]]
    
    let tableCellIdentifier = "sideMenuTableCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(dismissSideMenu(_:)), name:NSNotification.Name(rawValue: "sideMenuChromeTapped"), object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    // MARK: - Actions

    @IBAction func dismissSideMenu(_ sender: UISwipeGestureRecognizer) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func titleButtonTapped(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Table View Data Source

extension SideMenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 11.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 11.0))
        headerView.backgroundColor = UIColor.clear
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 11.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    
        if section < tableRowLabels.count - 1 {
            
            let footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 11.0))
            footerView.backgroundColor = UIColor.white
            let footerBottomBorderView = UIView(frame: CGRect(x: 0.0, y: 10.0, width: tableView.frame.size.width, height: 1.0))
            footerBottomBorderView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            footerView.addSubview(footerBottomBorderView)
            
            return footerView
        }
        
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return tableRowLabels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableRowLabels[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath)
        cell.textLabel?.text = tableRowLabels[indexPath.section][indexPath.row]
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
}

// Mark: - Table View Delegate

extension SideMenuViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let menuItem = tableRowLabels[indexPath.section][indexPath.row]
        
        dismiss(animated: true) {
            self.delegate?.sideMenuDidSelectItem(menuItem)
        }
    }
}
