//
//  GallerySaver.swift
//  Osmium
//
//  Created by Francesco on 05/06/24.
//

import UIKit

extension ViewController {
    
    func saveMediaToGallery(urlString: String) {
        guard let url = URL(string: urlString) else {
            writeToConsole("Invalid URL")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.handleMediaSavingError(error)
                return
            }
            
            guard let data = data else {
                self.handleMediaSavingError("No data received")
                return
            }
            
            guard let contentType = response?.mimeType else {
                self.handleMediaSavingError("Unknown content type")
                return
            }
            
            switch contentType {
            case _ where contentType.hasPrefix("image"):
                self.saveImageToGallery(data)
            case _ where contentType.hasPrefix("video"):
                self.saveVideoToGallery(data)
            default:
                self.handleMediaSavingError("Unsupported content type: \(contentType)")
            }
        }
        task.resume()
    }

    private func saveImageToGallery(_ imageData: Data) {
        guard let image = UIImage(data: imageData) else {
            handleMediaSavingError("Unable to create image from data")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        writeToConsole("Image saved to gallery successfully")
        showAlert(title: "Success", message: "Media saved to gallery successfully")
    }

    private func saveVideoToGallery(_ videoData: Data) {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("video.mp4")
        do {
            try videoData.write(to: tempURL)
            UISaveVideoAtPathToSavedPhotosAlbum(tempURL.path, nil, nil, nil)
            writeToConsole("Video saved to gallery successfully")
            showAlert(title: "Success", message: "Media saved to gallery successfully")
        } catch {
            handleMediaSavingError("Error saving video to gallery: \(error)")
        }
    }

    private func handleMediaSavingError(_ errorMessage: String) {
        writeToConsole("Error: \(errorMessage)")
        showAlert(title: "Error", message: errorMessage)
    }

    private func handleMediaSavingError(_ error: Error) {
        handleMediaSavingError(error.localizedDescription)
    }
}
