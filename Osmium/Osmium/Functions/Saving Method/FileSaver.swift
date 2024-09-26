//
//  FileSaver.swift
//  Osmium
//
//  Created by Francesco on 05/06/24.
//

import UIKit
import UserNotifications

extension ViewController: URLSessionDownloadDelegate {
    
    func saveMediaToDocumentsFolder(urlString: String) {
        guard let url = URL(string: urlString) else {
            writeToConsole("Invalid media URL")
            showAlert(title: "Error", message: "Invalid media URL")
            return
        }
        
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: "me.sobet.osmium.background")
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let response = downloadTask.response as? HTTPURLResponse,
              let url = downloadTask.originalRequest?.url else {
            writeToConsole("No response or invalid URL")
            showAlert(title: "Error", message: "Failed to download media")
            return
        }
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = response.suggestedFilename ?? url.lastPathComponent
        let destinationURL = documentsDirectory.appendingPathComponent(fileName)
        
        let shouldShareMedia = UserDefaults.standard.bool(forKey: userDefaultsKeyForSharing)
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: location, to: destinationURL)
            writeToConsole("File saved to: \(destinationURL.path)")
            
            DispatchQueue.main.async {
                self.downloadProgressLabel.text = "Download complete!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.downloadProgressLabel.isHidden = true
                }
                
                if shouldShareMedia {
                    self.shareAndDeleteFile(at: destinationURL)
                } else {
                    self.scheduleNotification()
                }
            }
        } catch {
            writeToConsole("Error handling media: \(error.localizedDescription)")
            showAlert(title: "Error", message: "Failed to handle media")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            self.downloadProgressLabel.isHidden = false
            if totalBytesExpectedToWrite > 0 {
                self.downloadProgressLabel.text = String(format: "Downloaded %.2f MB of %.2f MB", Double(totalBytesWritten) / 1_000_000, Double(totalBytesExpectedToWrite) / 1_000_000)
            } else {
                self.downloadProgressLabel.text = String(format: "Downloaded %.2f MB", Double(totalBytesWritten) / 1_000_000)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.writeToConsole("Error downloading media: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to download media")
            }
        }
    }
    
    private func shareAndDeleteFile(at url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { [weak self] (activityType, completed, returnedItems, error) in
            guard let self = self else { return }
            
            do {
                try FileManager.default.removeItem(at: url)
                self.writeToConsole("File deleted after sharing: \(url.path)")
            } catch {
                self.writeToConsole("Error deleting file after sharing: \(error.localizedDescription)")
            }
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Download Complete"
        content.body = "Your media file has been downloaded. It's time to save it!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.writeToConsole("Notification error: \(error.localizedDescription)")
            }
        }
    }
}
