//
//  OrdersViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 11/11/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class OrdersViewController: UITableViewController {

    @IBOutlet weak var tableHeaderLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        tableHeaderLabel.text = "Your Orders"
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ordersTableViewCell", for: indexPath) as! OrdersTableViewCell
        
        

        return cell
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }

}
