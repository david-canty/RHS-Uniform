//
//  LegalInformationViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 31/12/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import WebKit

enum LegalInformationType: String {
    case termsAndConditions = "Terms and Conditions"
    case privacyPolicy = "Privacy Policy"
}

class LegalInformationViewController: UIViewController {

    var informationType: LegalInformationType?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        loadContent()
    }
    
    func loadContent() {
        
        if let informationType = informationType {
        
            var filename = ""
            
            switch informationType {
            case .termsAndConditions:
                filename = "TermsAndConditions"
            case .privacyPolicy:
                filename = "PrivacyPolicy"
            }
            
            if let fileURL = Bundle.main.url(forResource: filename, withExtension: "rtf") {
                
                do {
                    
                    titleLabel.text = informationType.rawValue
                    
                    let fileContents = try NSAttributedString(url: fileURL, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                    
                    textView.attributedText = fileContents
  
                } catch {
                    
                    print("Error: contents of \(fileURL.absoluteString) could not be read")
                }
                
            } else {
                
                print("Error: \(filename).rtf could not be found")
            }
        }
    }
}
