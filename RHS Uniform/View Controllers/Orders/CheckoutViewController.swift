//
//  CheckoutViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 19/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class CheckoutViewController: UITableViewController {
    
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var itemsValueLabel: UILabel!
    @IBOutlet weak var postageLabel: UILabel!
    @IBOutlet weak var postageValueLabel: UILabel!
    @IBOutlet weak var orderTotalValueLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        navigationController?.navigationBar.shadowImage = UIImage(named: "nav_shadow")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        updateOrderSummaryLabels()
    }
    
    func updateOrderSummaryLabels() {
     
        let itemsTotal = 1
        itemsLabel.text = "Items: " + String(itemsTotal)
        
        let itemsValue = 9.99
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let formattedItemsValue = formatter.string(from: itemsValue as NSNumber)
        itemsValueLabel.text = formattedItemsValue
        
        postageLabel.text = "Postage & Packing: " + "Collection Only"
        
        let postageValue = 0.00
        let formattedPostageValue = formatter.string(from: postageValue as NSNumber)
        postageValueLabel.text = formattedPostageValue
        
        let orderTotal = 9.99
        let formattedTotalValue = formatter.string(from: orderTotal as NSNumber)
        orderTotalValueLabel.text = formattedTotalValue
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Button Actions
    
    @IBAction func cancelTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
