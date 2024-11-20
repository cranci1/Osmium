//
//  Instance.swift
//  Osmium
//
//  Created by Francesco on 20/10/24.
//

import UIKit

class Instance: UITableViewController {
    
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var keyLable: UILabel!
    @IBOutlet weak var autType: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateURLLabel()
        updateKeyLabel()
        
        if let authType = UserDefaults.standard.string(forKey: "authType") {
            autType.setTitle(authType, for: .normal)
        } else {
            autType.setTitle("select", for: .normal)
        }
    }
    
    @IBAction func enterURLButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Enter Instance URL", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "https://api.cobalt.tools"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            if let urlText = alertController.textFields?.first?.text {
                UserDefaults.standard.set(urlText, forKey: "requestURL")
                
                self?.updateURLLabel()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func updateURLLabel() {
        if let savedURL = UserDefaults.standard.string(forKey: "requestURL") {
            urlLabel.text = "Instance URL: \(savedURL)"
        } else {
            urlLabel.text = "No URL is provided"
        }
    }
    
    @IBAction func authKeyButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Enter Auth Key", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter your authentication key"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let authKeyText = alertController.textFields?.first?.text {
                UserDefaults.standard.set(authKeyText, forKey: "authKey")
                self.updateKeyLabel()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func updateKeyLabel() {
        if let authKeyText = UserDefaults.standard.string(forKey: "authKey") {
            keyLable.text = "Auth Key: \(authKeyText)"
        } else {
            keyLable.text = "No Key is provided"
        }
    }

    @IBAction func authTypeButtonTapped(_ sender: UIButton) {
        let bearerAction = UIAction(title: "Bearer") { _ in
            UserDefaults.standard.set("Bearer", forKey: "authType")
            self.autType.setTitle("Bearer", for: .normal)
        }
        
        let apiKeyAction = UIAction(title: "API-Key") { _ in
            UserDefaults.standard.set("API-Key", forKey: "authType")
            self.autType.setTitle("API-Key", for: .normal)
        }
        
        let noneAction = UIAction(title: "None") { _ in
            UserDefaults.standard.removeObject(forKey: "authType")
            self.autType.setTitle("select", for: .normal)
        }
        
        let menu = UIMenu(title: "Select Auth Type", children: [bearerAction, apiKeyAction, noneAction])
        
        autType.menu = menu
        autType.showsMenuAsPrimaryAction = true
    }
}
