//
//  AboutViewController.swift
//  SMS-13033
//
//  Created by Ioanna Z. on 11/11/20.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet var aboutTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("About-Header", comment: "About-title")

        aboutTextView.text = NSLocalizedString("About", comment: "")
    }
    
}
