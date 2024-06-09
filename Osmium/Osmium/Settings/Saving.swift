//
//  Saving.swift
//  Osmium
//
//  Created by Francesco on 07/06/24.
//

import UIKit

class Saving: UITableViewController {
    
    @IBOutlet weak var saveMedias: UISwitch!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveMedias.isOn = UserDefaults.standard.bool(forKey: "saveMedia")
    }
    
    @IBAction func switchSaveVideo(_ sender: UISwitch) {
        let isEnabled = sender.isOn
        UserDefaults.standard.set(isEnabled, forKey: "saveMedia")
        NotificationCenter.default.post(name: Notification.Name("sSaveMedia"), object: nil, userInfo: ["saveMedia": isEnabled])
    }
    
    @IBAction func deleteTemporaryDirectory(_ sender: Any) {
        let alertController = UIAlertController(title: "Clear 'tmp' folder", message: "Are you sure you want to clear the 'tmp' folder?", preferredStyle: .alert)
        let fileManager = FileManager.default
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { _ in
            do {
                let contents = try fileManager.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil, options: [])
                for file in contents {
                    try fileManager.removeItem(at: file)
                }
            } catch {
                print("Error clearing temporary directory: \(error.localizedDescription)")
            }
        }))
        
        present(alertController, animated: true, completion: nil)
    }
}

