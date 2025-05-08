//
//  FileSaver.swift
//  Osmium
//
//  Created by Francesco on 05/06/24.
//

import UIKit
import UserNotifications

extension ViewController: MediaSaverDelegate {
    func saveMediaToDocumentsFolder(urlString: String) {
        DispatchQueue.main.async {
            self.downloadProgressLabel.isHidden = false
            MediaSaver.shared.delegate = self
            MediaSaver.shared.saveMedia(from: urlString)
        }
    }
    
    func mediaSaver(_ saver: MediaSaver, didUpdateProgressText text: String) {
        downloadProgressLabel.isHidden = false
        downloadProgressLabel.text = text
    }
    
    func mediaSaver(_ saver: MediaSaver, didUpdateProgress progress: Double) {
        let percentage = Int(progress * 100)
        downloadProgressLabel.text = "Downloaded \(percentage)%"
    }
    
    func mediaSaver(_ saver: MediaSaver, didFinishSavingAt url: URL) {
        handleSuccessfulSave(at: url)
    }
    
    func mediaSaver(_ saver: MediaSaver, didFailWithError error: MediaSavingError) {
        handleSavingError(error)
    }
    
    private func handleSuccessfulSave(at url: URL) {
        writeToConsole("File saved to: \(url.path)")
        downloadProgressLabel.text = "Download complete!"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.downloadProgressLabel.isHidden = true
        }
        
        if UserDefaults.standard.bool(forKey: userDefaultsKeyForSharing) {
            shareAndDeleteFile(at: url)
        } else {
            scheduleNotification()
        }
    }
    
    private func handleSavingError(_ error: MediaSavingError) {
        writeToConsole(error.localizedDescription)
        showAlert(title: "Error", message: error.localizedDescription)
        downloadProgressLabel.isHidden = true
    }
    
    private func shareAndDeleteFile(at url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { [weak self] (_, _, _, error) in
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
