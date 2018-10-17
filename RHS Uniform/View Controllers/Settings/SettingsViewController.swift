//
//  SettingsViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 01/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var hapticsSwitch: UISwitch!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let useHaptics = userDefaults.bool(forKey: "useHaptics")
        hapticsSwitch.setOn(useHaptics, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    // MARK: - Actions
    
    @IBAction func hapticsSwitchDidChangeValue(_ sender: UISwitch) {
        
        let useHaptics = sender.isOn
        userDefaults.set(useHaptics, forKey: "useHaptics")
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
    }

}

extension SettingsViewController {
    
    
}
