//
//  ViewController.swift
//  Osmium
//
//  Created by Francesco on 28/05/24.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var clearConsoleButton: UIButton!
    @IBOutlet weak var downloadProgressLabel: UILabel!
    
    var debug = UserDefaults.standard.bool(forKey: "debugPlease")
    var saveMedia = UserDefaults.standard.bool(forKey: "saveMedia")
    
    let userDefaultsKeyForSharing = "shouldShareMedia"
    let choices = ["max", "2160", "1440", "1080", "720", "480", "360", "240", "144"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestNotificationPermission()
        
        consoleTextView.text = "Console Output:"
        consoleTextView.layer.cornerRadius = 16
        consoleTextView.layer.masksToBounds = true
        
        urlTextField.delegate = self
        urlTextField.text = UserDefaults.standard.string(forKey: "url")
        
        let selectedChoiceIndex = UserDefaults.standard.integer(forKey: "SelectedChoiceIndex")
        UserDefaults.standard.set(choices[selectedChoiceIndex], forKey: "vQuality")
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectedChoiceChanged(_:)), name: Notification.Name("SelectedChoiceChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSaveMedia(_:)), name: Notification.Name("sSaveMedia"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDebug(_:)), name: Notification.Name("dDebugPlease"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        let moveDistance = keyboardFrame.height / 2

        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y -= moveDistance
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y = 0
        }
    }

    @objc func selectedChoiceChanged(_ notification: Notification) {
        guard let selectedIndex = notification.object as? Int else { return }
        guard selectedIndex >= 0 && selectedIndex < choices.count else { return }
        UserDefaults.standard.set(choices[selectedIndex], forKey: "vQuality")
    }
    
    @IBAction func sendRequestButtonTapped(_ sender: UIButton) {
        sendPostRequest()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func writeToConsole(_ messages: Any...) {
        DispatchQueue.main.async {
            let concatenatedMessage = messages.map { "\($0)" }.joined(separator: " ")
            self.consoleTextView.text.append("\n\(concatenatedMessage)")
        }
    }

    
    @IBAction func clearConsoleButtonTapped(_ sender: UIButton) {
        clearConsole()
    }
    
    func clearConsole() {
        consoleTextView.text = "Console Output:"
    }
}
