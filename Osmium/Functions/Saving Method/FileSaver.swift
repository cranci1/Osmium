//
//  FileSaver.swift
//  Osmium
//
//  Created by Francesco on 05/06/24.
//

import UIKit

extension ViewController: URLSessionDownloadDelegate {
    
    func saveMediaToTempFolder(urlString: String) {
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
    
    func randomizedFileName(from originalName: String) -> String {
        let randomString = UUID().uuidString
        let fileExtension = (originalName as NSString).pathExtension
        return "\(randomString).\(fileExtension)"
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let response = downloadTask.response else {
            writeToConsole("No response")
            showAlert(title: "Error", message: "Failed to download media")
            return
        }
        
        let url = downloadTask.originalRequest?.url
        do {
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = response.suggestedFilename ?? self.randomizedFileName(from: url?.lastPathComponent ?? "unknown")
            var tempURL = tempDirectory.appendingPathComponent(fileName)
            
            var count = 1
            let fileManager = FileManager.default
            while fileManager.fileExists(atPath: tempURL.path) {
                let newName = "\(tempURL.deletingPathExtension().lastPathComponent)-\(count).\(tempURL.pathExtension)"
                tempURL = tempDirectory.appendingPathComponent(newName)
                count += 1
            }
            
            try fileManager.moveItem(at: location, to: tempURL)
            self.writeToConsole("Media saved to: \(tempURL.path)")
            self.openShareView(with: tempURL)
            
            DispatchQueue.main.async {
                self.downloadProgressLabel.text = "Download complete!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.downloadProgressLabel.isHidden = true
                }
            }
            scheduleNotification()
            
        } catch {
            self.writeToConsole("Error saving media: \(error.localizedDescription)")
            self.showAlert(title: "Error", message: "Failed to save media")
            self.clearTmpFolder()
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            self.downloadProgressLabel.isHidden = false
            if totalBytesExpectedToWrite > 0 {
                _ = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
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
    
    private func scheduleNotification() {
         let content = UNMutableNotificationContent()
         content.title = "Download Complete"
         content.body = "Your media file has been downloaded. It's time to save it!"
         content.sound = .default

         let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
         let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

         UNUserNotificationCenter.current().add(request) { error in
             if let error = error {
                 print("Notification error: \(error.localizedDescription)")
             }
         }
     }
}
