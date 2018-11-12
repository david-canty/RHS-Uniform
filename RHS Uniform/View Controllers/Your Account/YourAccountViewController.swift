//
//  YourAccountViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 16/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import FirebaseAuth

class YourAccountViewController: UITableViewController {
    
    var firebaseAuth: Auth?
    var user: User?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        firebaseAuth = Auth.auth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let user = firebaseAuth?.currentUser {
            
            self.user = user
                
            nameLabel.text = user.displayName ?? "Not entered"
            emailLabel.text = user.email
        }
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "changeName" {
            
            let nameVC = segue.destination as! ChangeNameViewController
            nameVC.currentName = user?.displayName
        }
    }

}

extension YourAccountViewController {
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 38.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let tableViewFrameWidth = tableView.frame.size.width
        
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableViewFrameWidth, height: 38.0))
        headerView.backgroundColor = UIColor(red: 62.0/255.0, green: 60.0/255.0, blue: 146.0/255.0, alpha: 0.8)
        
        let headerLabel = UILabel(frame: CGRect(x: 16.0, y: 0.0, width: tableViewFrameWidth - 32.0, height: 38.0))
        headerLabel.backgroundColor = UIColor.clear
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont(name: "Arial-BoldMT", size: 14.0)
        headerLabel.textAlignment = .left
        
        switch section {
        case 0:
            headerLabel.text = "Sign In & Security"
        case 1:
            headerLabel.text = "Section Title"
        default:
            break
        }
        
        headerView.addSubview(headerLabel)
        
        return headerView
    }
}
