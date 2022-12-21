//
//  ViewController.swift
//  SMS-13033
//
//  Created by Ioanna Z. on 9/11/20.
//

import UIKit
import MessageUI

class ViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
    var reasons = [String]()
    var codeNumbers = [String]()
    var userFullName: String = ""
    var userAddress: String = ""
    var noTimeConstraints = ["Health", "Transport", "Pet"]
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result{
        case .cancelled:
            //print("SMS was cancelled")
            
            controller.dismiss(animated: true, completion: nil)
        case .failed:
            //print("Failed to send SMS")
            
            controller.dismiss(animated: true, completion: nil)
            
            let ac = UIAlertController(title: NSLocalizedString("SMS-Failed", comment: ""), message: NSLocalizedString("SMS-Not-Sent", comment: ""), preferredStyle: .alert)
            ac.addAction((UIAlertAction(title: "OK", style: .destructive, handler: nil)))
            present(ac, animated: true, completion: nil)
        case .sent:
            //print("SMS was sent")
            
            controller.dismiss(animated: true, completion: nil)
            
            let ac = UIAlertController(title: NSLocalizedString("Attention", comment: ""), message: NSLocalizedString("Prompt-Look-Inbox", comment: ""), preferredStyle: .alert)
            ac.addAction((UIAlertAction(title: "OK", style: .default, handler: nil)))
            present(ac, animated: true, completion: nil)
        @unknown default:
            fatalError()
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("Choices-Header", comment: "reason of movement")
        
        if let optionsURL = Bundle.main.url(forResource: "options", withExtension: ".txt") {
            if let optionsContents = try? String(contentsOf: optionsURL) {
                let lines = optionsContents.components(separatedBy: "\n")
                
                for (_, line) in lines.enumerated() {
                    let parts = line.components(separatedBy: ":")
                    let reason = parts[1]
                    let code = parts[0]
                    
                    reasons.append(reason)
                    codeNumbers.append(code)
                }
            }
        }
        
        // Remove here any movement that is no longer allowed - careful with index number !
        reasons.remove(at: 4) // schools closed atm
        codeNumbers.remove(at: 4)
        
//        print("Choose one of reasons for moving: \(reasons)") // testing
//        print("CodeNumbers available: \(codeNumbers)") // testing
//        retrieveUserInfo() // testing
//        print("User's info:\nFull Name: \(userFullName)\nAddress: \(userAddress)") // testing
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        for i in 1...10 {
            if (indexPath.row + 1) == i {
                cell.textLabel?.text = NSLocalizedString(reasons[indexPath.row], comment: "")
                cell.imageView?.image = UIImage(named: reasons[indexPath.row])
            }
        }
        
        cell.textLabel?.numberOfLines = 0
        
        cell.layer.borderWidth = 0.5
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Load user's saved info
        retrieveUserInfo()
        
        //print("SMS to send:\n\(codeNumbers[indexPath.row]) \(userFullName) \(userAddress)\n") // testing
        //print("reason for movement \(reasons[indexPath.row]) has no time constraints: \(noTimeConstraints.contains(reasons[indexPath.row]))\n") // testing
        
        // Check user has entered info
        if !isUserInfoFilled() {
            tableView.deselectRow(at: indexPath, animated: true)
            //print("User's Info are not filled") // test
            
            let ac = UIAlertController(title: NSLocalizedString("Attention", comment: ""), message: NSLocalizedString("Fill-Info", comment: ""), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("Do-Fill-Info", comment: ""), style: .default) { [weak self] _ in
                self?.tabBarController?.selectedIndex = 1 // send user to the Info tab
            })
            ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)            
        } else {
            // If we have user's info, continue with next check
            
            // Show extra alert for the transport spouse option
            if reasons[indexPath.row] == "Transport" {
                showTransportAlert(at: indexPath)
            } else {
                // Continue for all other options
                
                // If movement option has no time constraints
                if noTimeConstraints.contains(reasons[indexPath.row]) {
                    showConfirmAlert(at: indexPath)
                } else {
                    // If time constraints apply, check time and proceed or show a warning
                    if isWithinTimeConstraints() {
                        showConfirmAlert(at: indexPath)
                    } else {
                        showTimeWarning(at: indexPath)
                    }
                }
            }
        }
    }
    
    func sendMessage(at indexPath: IndexPath) {
        //print("CodeNumber to send is: \(codeNumbers[indexPath.row]) for Choice: \(reasons[indexPath.row] )") // debug-test that selected cell gives us the right code No
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !MFMessageComposeViewController.canSendText() {
            //print("SMS Services are not available") // debugger
            
            let ac = UIAlertController(title: NSLocalizedString("No-SMS-Title", comment: "attention"), message: NSLocalizedString("No-SMS-Body", comment: "SMS services not available"), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let smsVC = MFMessageComposeViewController()
            smsVC.recipients = ["13033"]
            smsVC.body = "\(codeNumbers[indexPath.row]) \(userFullName) \(userAddress)"
            smsVC.messageComposeDelegate = self
            
            self.present(smsVC, animated: true, completion: nil)
        }
    }
    
    // Load user's saved info
    func retrieveUserInfo() {
        if let usersName = (KeychainService.loadPassword(serviceKey: ("usersName"))),
           let usersAddress = (KeychainService.loadPassword(serviceKey: ("usersAddress"))) {
            userFullName = usersName
            userAddress = usersAddress
        } else {
            userFullName = ""
            userAddress = ""
        }
    }
    // Setting info to empty strings otherwise the var values remain the same. Scenario: some data saved, later deleted. keychain gets deleted but these variables here retain the previous data, until app is terminated. => so when user tapped a cell-choice, they weren't prompted to insert data and previous values were used.
    
    
    func isUserInfoFilled() -> Bool {
        if userFullName.isEmpty || userAddress.isEmpty {
            return false
        }
        return true
    }
    
    func isWithinTimeConstraints() -> Bool {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date) // returns it in 24h format
        
        //print("Hour of the day is: \(hour)\n") // test
        
        // ATM curfew is between 21:00-5:00
        let startHour = 5
        let endHour = 20 // includes 20:59, so it's good
        let timeRangeAllowed = startHour...endHour
        
        //print("Allowed time range: \(timeRangeAllowed)\n") //test
        
        return timeRangeAllowed.contains(hour)
    }
    
    func showConfirmAlert(at indexPath: IndexPath) {
        let ac = UIAlertController(title: NSLocalizedString("Confirmation", comment: "confirm choice"), message: NSLocalizedString(reasons[indexPath.row], comment: ""), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.sendMessage(at: indexPath)
        }))
        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { [weak self] _ in
            self?.tableView.deselectRow(at: indexPath, animated: true)} )
        // handler deselects the cell after pressing cancel
        present(ac, animated: true)
    }
    
    func showTimeWarning(at indexPath: IndexPath) {
        let ac = UIAlertController(title: ("\(NSLocalizedString("Warning", comment: ""))!\n\(NSLocalizedString("Curfew", comment: ""))"), message: "\(NSLocalizedString("User-Selected", comment: ""))\(NSLocalizedString(reasons[indexPath.row], comment: "user's choice"))", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("Ignore-Warning", comment: ""), style: .default, handler: { [weak self] _ in
            self?.sendMessage(at: indexPath)
        }))
        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive) { [weak self] _ in self?.tableView.deselectRow(at: indexPath, animated: true)} )
        present(ac, animated: true, completion: nil)
    }
    
    func showTransportAlert(at indexPath: IndexPath) {
        let ac = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Spouse-Perm", comment: "requires permission document"), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.sendMessage(at: indexPath)
        }))
        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { [weak self] _ in self?.tableView.deselectRow(at: indexPath, animated: true)} )
        present(ac, animated: true)
    }
    
}
