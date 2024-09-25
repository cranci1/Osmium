//
//  ImageSaver.swift
//  Osmium
//
//  Created by Francesco on 25/09/24.
//
//  Code is from the AnimeGen project made by me https://github.com/cranci1/AnimeGen

import UIKit
import Photos
import MobileCoreServices

extension ViewController {
    @objc func saveImage(imageString: String) {
        guard let imageUrl = URL(string: imageString) else {
            return
        }
        
        downloadImage(from: imageUrl) { [weak self] imageData, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                self.writeToConsole("Error downloading image: \(error.localizedDescription)")
                return
            }
            
            guard let data = imageData else {
                return
            }
            
            if let source = CGImageSourceCreateWithData(data as CFData, nil),
               let utType = CGImageSourceGetType(source),
               UTTypeConformsTo(utType, kUTTypeGIF) {
                self.saveGIFImage(data: data)
                self.writeToConsole("Saving GIF image")
            } else if let uiImage = UIImage(data: data) {
                self.saveJPEGImage(uiImage: uiImage)
                self.writeToConsole("Saving image")
            } else {
                print("Error converting image to JPEG format")
                self.writeToConsole("Error converting image to JPEG format")
            }
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, nil)
                return
            }
            
            completion(data, nil)
        }
        task.resume()
    }
    
    private func saveGIFImage(data: Data) {
        PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: data, options: nil)
        } completionHandler: { [weak self] success, error in
            guard let self = self else { return }
            if success {
                print("GIF image saved to Photos library")
                self.writeToConsole("GIF image saved to Photos library")
            } else {
                print("Error saving GIF image: \(error?.localizedDescription ?? "")")
                self.writeToConsole("Error saving GIF image: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    private func saveJPEGImage(uiImage: UIImage) {
        UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    private func saveVideo(data: Data) {
        PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .video, data: data, options: nil)
        } completionHandler: { [weak self] success, error in
            guard let self = self else { return }
            if success {
                print("Video saved to Photos library")
                self.writeToConsole("Video saved to Photos library")
            } else {
                print("Error saving video: \(error?.localizedDescription ?? "")")
                self.writeToConsole("Error saving video: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
            self.writeToConsole("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully")
            self.writeToConsole("Image saved successfully")
        }
    }
}
