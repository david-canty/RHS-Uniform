//
//  ModalSelectViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 19/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

protocol ModalSelectViewControllerDelegate {
    
    func modalSelectDidSelect(item: [String: Any])
}

class ModalSelectViewController: UIViewController {

    var delegate: ModalSelectViewControllerDelegate?
    let notificationCenter = NotificationCenter.default
    
    var titleString = ""
    var tableRowData = [[String: Any]]()
    var selectedRow = 0
    
    let tableCellIdentifier = "modelSelectTableCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(closeTapped(_:)), name:NSNotification.Name(rawValue: "modalSelectChromeTapped"), object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(dataInvalidated(notification:)), name: NSNotification.Name(rawValue: "modalSelectDataInvalidated"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        titleLabel.text = titleString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let selectedRowindexPath = IndexPath(row: selectedRow, section: 0)
        tableView.scrollToRow(at: selectedRowindexPath, at: .top, animated: true)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func dataInvalidated(notification: NSNotification) {
        
        guard let title = notification.userInfo?["title"] as? String else { return }
        guard let message = notification.userInfo?["message"] as? String else { return }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = UIColor(red: 203.0/255.0, green: 8.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        
        let alertAction = UIAlertAction(title: "Close", style: .default) { (action) in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Actions

    @IBAction func closeTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Table View Data Source

extension ModalSelectViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableRowData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 38.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath)
        cell.textLabel?.text = tableRowData[indexPath.row]["itemLabel"] as? String
        
        cell.accessoryType = indexPath.row == selectedRow ? .checkmark : .none
        
        return cell
    }
}

// Mark: - Table View Delegate

extension ModalSelectViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.modalSelectDidSelect(item: tableRowData[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
}
