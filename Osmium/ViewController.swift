//
//  ViewController.swift
//  Osmium
//
//  Created by Francesco on 28/05/24.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var clearConsoleButton: UIButton!
    
    var debug = UserDefaults.standard.bool(forKey: "debugPlease")
    
    var saveMedia = UserDefaults.standard.bool(forKey: "saveMedia")
    
    let choices = ["max", "2160", "1440", "1080", "720", "480", "360", "240", "144"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func getUserDefaultsValue<T>(key: String, defaultValue: T) -> T {
        return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
    }
    
    func sendPostRequest() {
        guard let urlText = urlTextField.text, !urlText.isEmpty else {
            writeToConsole("URL text field is empty")
            showAlert(title: "Error", message: "Please enter a valid URL")
            return
        }
        
        self.writeToConsole("Starting process...")
        
        UserDefaults.standard.set(urlText, forKey: "url")
        
        guard let url = URL(string: "https://api.cobalt.tools/api/json") else { return }

        let requestBody: [String: Any] = [
            "url": getUserDefaultsValue(key: "url", defaultValue: "https://example.com/video"),
            "vCodec": getUserDefaultsValue(key: "vCodec", defaultValue: "h264"),
            "vQuality": getUserDefaultsValue(key: "vQuality", defaultValue: "720"),
            "aFormat": getUserDefaultsValue(key: "aFormat", defaultValue: "mp3"),
            "filenamePattern": getUserDefaultsValue(key: "filenamePattern", defaultValue: "classic"),
            "isAudioOnly": getUserDefaultsValue(key: "isAudioOnly", defaultValue: false),
            "isTTFullAudio": getUserDefaultsValue(key: "isTTFullAudio", defaultValue: false),
            "isAudioMuted": getUserDefaultsValue(key: "isAudioMuted", defaultValue: false),
            "dubLang": getUserDefaultsValue(key: "dubLang", defaultValue: false),
            "disableMetadata": getUserDefaultsValue(key: "disableMetadata", defaultValue: false),
            "twitterGif": getUserDefaultsValue(key: "twitterGif", defaultValue: false),
            "tiktokH265": getUserDefaultsValue(key: "tiktokH265", defaultValue: false)
        ]
        
        if debug {
            writeToConsole("Request Body:")
            for (key, value) in requestBody {
                writeToConsole("\(key): \(value)")
            }
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            writeToConsole("Failed to serialize JSON data")
            showAlert(title: "Error", message: "Failed to process request")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.writeToConsole("Error: \(error)")
                self.showAlert(title: "Error", message: "Failed to process request")
                return
            }
            
            guard let data = data else {
                self.writeToConsole("No data")
                self.showAlert(title: "Error", message: "No data received")
                return
            }
            
            if self.debug {
                if let responseString = String(data: data, encoding: .utf8) {
                    self.writeToConsole("Response: \(responseString)")
                } else {
                    self.writeToConsole("Unable to convert response data to string")
                }
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = json["status"] as? String,
               let mediaURLString = json["url"] as? String {
                if status == "redirect" {
                    if self.saveMedia {
                        self.saveMediaToGallery(urlString: mediaURLString)
                    } else {
                        self.openURLInSafari(urlString: mediaURLString)
                    }
                    self.writeToConsole("Saving media...")
                } else if status == "stream" {
                    self.openURLInSafari(urlString: mediaURLString)
                    self.writeToConsole("Opening link...")
                } else {
                    self.writeToConsole("Unexpected status in response")
                    self.showAlert(title: "Error", message: "Unexpected status in response")
                }
            } else {
                self.writeToConsole("Error parsing JSON or extracting media URL from response")
                self.showAlert(title: "Error", message: "Failed to parse response")
            }
        }
        task.resume()
    }

    func openURLInSafari(urlString: String) {
        guard let url = URL(string: urlString) else {
            writeToConsole("Invalid URL")
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            self.writeToConsole("Done!")
        }
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

    func saveMediaToGallery(urlString: String) {
        guard let url = URL(string: urlString) else {
            writeToConsole("Invalid URL")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                self.writeToConsole("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self.writeToConsole("No data received")
                return
            }
            
            if let contentType = response?.mimeType {
                if contentType.hasPrefix("image") {
                    if let image = UIImage(data: data) {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        self.writeToConsole("Image saved to gallery successfully")
                        self.showAlert(title: "Success", message: "Media saved to gallery successfully")
                    } else {
                        self.writeToConsole("Unable to create image from data")
                    }
                } else if contentType.hasPrefix("video") {
                    let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("video.mp4")
                    do {
                        try data.write(to: tempURL)
                        UISaveVideoAtPathToSavedPhotosAlbum(tempURL.path, nil, nil, nil)
                        self.writeToConsole("Video saved to gallery successfully")
                        self.showAlert(title: "Success", message: "Media saved to gallery successfully")
                    } catch {
                        self.writeToConsole("Error saving video to gallery: \(error)")
                    }
                } else {
                    self.writeToConsole("Unsupported content type: \(contentType)")
                }
            } else {
                self.writeToConsole("Unknown content type")
            }
        }
        task.resume()
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
