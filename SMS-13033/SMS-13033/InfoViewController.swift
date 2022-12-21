//
//  InfoViewController.swift
//  SMS-13033
//
//  Created by Ioanna Z. on 11/11/20.
//

import UIKit
import Security

class InfoViewController: UIViewController {
    @IBOutlet var surnameTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Info-Header", comment: "Info-title")
        
        surnameTextField.placeholder = NSLocalizedString("FullName", comment: "")
        addressTextField.placeholder = NSLocalizedString("Address", comment: "")
        
        // Images for the textfields
        if #available(iOS 13.0, *) {
            let nameImage = UIImage(systemName: "person")
            let nameImageView = UIImageView(image: nameImage)
            surnameTextField.leftView = nameImageView
        } else {
            // Fallback on earlier versions
            if let nameImage = UIImage(named: "person40px") {
            let nameImageView = UIImageView(image: nameImage)
            nameImageView.contentMode = .center
            nameImageView.frame = CGRect(x: 0, y: 0, width: nameImage.size.width + 10, height: nameImage.size.height)
            surnameTextField.leftView = nameImageView
            }
        }
        surnameTextField.leftViewMode = .always
        
        if #available(iOS 13.0, *) {
            let addressImage = UIImage(systemName: "house")
            let addressImageView = UIImageView(image: addressImage)
            addressTextField.leftView = addressImageView
        } else {
            // Fallback on earlier versions
            if let addressImage = UIImage(named: "house40px") {
            let addressImageView = UIImageView(image: addressImage)
            addressImageView.contentMode = .center
            addressImageView.frame = CGRect(x: 0, y: 0, width: addressImage.size.width + 10, height: addressImage.size.height)
            addressTextField.leftView = addressImageView
            }
        }
        addressTextField.leftViewMode = .always
        
        // .contentMode and .frame lines are needed to create padding, else image hides the border of the textfield
        
        addressTextField.inputAssistantItem.leadingBarButtonGroups = []
        addressTextField.inputAssistantItem.trailingBarButtonGroups = []
        surnameTextField.inputAssistantItem.leadingBarButtonGroups = []
        surnameTextField.inputAssistantItem.trailingBarButtonGroups = []
        // 4 lines above hide shortcuts altogether (bar above keyboard in iPad). NSLayout problem when running in iPad, which seems to only happen for a UITextField that has autocorrection disabled or is secure. In that case no shortcuts are available, and this bar frame is set to a zero CGRect. This causes auto-layout problems.
   
        loadSavedInfo()
        
        saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        saveButton.layer.cornerRadius = 15
        saveButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        deleteButton.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
        deleteButton.layer.cornerRadius = 15
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = deleteButton.titleLabel?.textColor.cgColor
        deleteButton.titleLabel?.adjustsFontForContentSizeCategory = true
 
    }
    
    // Delete user's data
    @IBAction func deleteTapped(_ sender: UIButton) {
        KeychainService.removePassword(serviceKey: "usersName")
        KeychainService.removePassword(serviceKey: "usersAddress")
        
        surnameTextField.text = ""
        addressTextField.text = ""
        
        let ac = UIAlertController(title: NSLocalizedString("Data-Deleted", comment: "data saved succesfully"), message: nil, preferredStyle: .alert)
         ac.addAction(UIAlertAction(title: "OK", style: .default))
         present(ac, animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        if surnameTextField.hasText && addressTextField.hasText {
            save()
        } else {
            checkEntryForm()
        }
    }
    
    // Save personal info with Keychain
    func save() {
        if let usersName = surnameTextField.text, let usersAddress = addressTextField.text {
            KeychainService.updatePassword(usersName, serviceKey: "usersName")
            KeychainService.updatePassword(usersAddress, serviceKey: "usersAddress")
            
            self.view.endEditing(true) // to hide keyboard. doesn't work if i put it after the alert
            
            let ac = UIAlertController(title: NSLocalizedString("Data-Saved", comment: "data saved succesfully"), message: nil, preferredStyle: .alert)
             ac.addAction(UIAlertAction(title: "OK", style: .default))
             present(ac, animated: true)
            
            //print("Info saved successfully.\nUser's name: \(usersName)\nUser's address: \(usersAddress)") // test
        }
    }
    
    // Check which info isn't filled and show alert
    func checkEntryForm() {
        if !surnameTextField.hasText && !addressTextField.hasText {
            let ac = UIAlertController(title: NSLocalizedString("Attention", comment: ""), message: NSLocalizedString("Fill-Info", comment: ""), preferredStyle: .alert)
            ac.addAction((UIAlertAction(title: "OK", style: .cancel, handler: nil)))
            present(ac, animated: true, completion: nil)
            
            //print("You need to fill all your info") // test
        } else if !surnameTextField.hasText && addressTextField.hasText {
            let ac = UIAlertController(title: NSLocalizedString("Attention", comment: ""), message: NSLocalizedString("Fill-Name", comment: ""), preferredStyle: .alert)
            ac.addAction((UIAlertAction(title: "OK", style: .cancel, handler: nil)))
            present(ac, animated: true, completion: nil)
    
            //print("You need to fill your name") // test
        } else if surnameTextField.hasText && !addressTextField.hasText {
            let ac = UIAlertController(title: NSLocalizedString("Attention", comment: ""), message: NSLocalizedString("Fill-Address", comment: ""), preferredStyle: .alert)
            ac.addAction((UIAlertAction(title: "OK", style: .cancel, handler: nil)))
            present(ac, animated: true, completion: nil)
            
            //print("You need to fill your address") // test
        }
    }
    
    // Load user's saved info
    func loadSavedInfo() {
        if let usersName = (KeychainService.loadPassword(serviceKey: ("usersName"))) {
            surnameTextField.text = usersName
        }
        if let usersAddress = (KeychainService.loadPassword(serviceKey: ("usersAddress"))) {
            addressTextField.text = usersAddress
        }
    }
    
    // Hide keyboard when touching outside textfields
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
