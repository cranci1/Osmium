//
//  Request.swift
//  Osmium
//
//  Created by Francesco on 05/06/24.
//

import UIKit

extension ViewController {
    
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
        
        guard let url = URL(string: "https://api.cobalt.tools/api/json") else {
            writeToConsole("Invalid API URL")
            showAlert(title: "Error", message: "Invalid API URL")
            return
        }
        
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
            requestBody.forEach { key, value in
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
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
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
            
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw NSError(domain: "ParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])
                }
                
                guard let status = jsonObject["status"] as? String, let mediaURLString = jsonObject["url"] as? String else {
                    throw NSError(domain: "ParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to extract required data from JSON"])
                }
                
                switch status {
                case "redirect", "stream":
                    if self.saveMedia {
                        self.saveMediaToTempFolder(urlString: mediaURLString)
                        self.writeToConsole("Saving media to temp folder...")
                    } else {
                        self.openURLInSafari(urlString: mediaURLString)
                        self.writeToConsole("Opening link...")
                    }
                    
                default:
                    self.writeToConsole("Unexpected status in response")
                    self.showAlert(title: "Error", message: "Unexpected status in response")
                }
            } catch {
                self.writeToConsole("Error: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to parse response")
            }
        }
        task.resume()
    }
}
