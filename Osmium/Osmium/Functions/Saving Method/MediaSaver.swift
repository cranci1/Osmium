import UIKit
import Photos
import UserNotifications

protocol MediaSaverDelegate: AnyObject {
    func mediaSaver(_ saver: MediaSaver, didUpdateProgress progress: Double)
    func mediaSaver(_ saver: MediaSaver, didUpdateProgressText text: String)
    func mediaSaver(_ saver: MediaSaver, didFinishSavingAt url: URL)
    func mediaSaver(_ saver: MediaSaver, didFailWithError error: MediaSavingError)
}

enum MediaSavingError: Error {
    case invalidURL
    case downloadFailed(Error)
    case savingFailed(Error)
    case invalidResponse
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid media URL"
        case .downloadFailed(let error): return "Download failed: \(error.localizedDescription)"
        case .savingFailed(let error): return "Saving failed: \(error.localizedDescription)"
        case .invalidResponse: return "Invalid server response"
        }
    }
}

class MediaSaver: NSObject, URLSessionDownloadDelegate {
    static let shared = MediaSaver()
    weak var delegate: MediaSaverDelegate?
    private var session: URLSession!
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private override init() {
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: operationQueue)
    }
    
    func saveMedia(from urlString: String) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.delegate?.mediaSaver(self, didFailWithError: .invalidURL)
            }
            return
        }
        
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let response = downloadTask.response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
                  DispatchQueue.main.async {
                      self.delegate?.mediaSaver(self, didFailWithError: .invalidResponse)
                  }
                  return
              }
        do {
            let savedURL = try moveToDocuments(from: location, response: response)
            DispatchQueue.main.async {
                self.delegate?.mediaSaver(self, didFinishSavingAt: savedURL)
            }
        } catch {
            DispatchQueue.main.async {
                self.delegate?.mediaSaver(self, didFailWithError: .savingFailed(error))
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            self.delegate?.mediaSaver(self, didUpdateProgress: progress)
            
            let progressText: String
            if totalBytesExpectedToWrite > 0 {
                progressText = String(format: "Downloaded %.2f MB of %.2f MB", Double(totalBytesWritten) / 1_000_000, Double(totalBytesExpectedToWrite) / 1_000_000)
            } else {
                progressText = String(format: "Downloaded %.2f MB", Double(totalBytesWritten) / 1_000_000)
            }
            self.delegate?.mediaSaver(self, didUpdateProgressText: progressText)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.delegate?.mediaSaver(self, didFailWithError: .downloadFailed(error))
            }
        }
    }
    
    private func moveToDocuments(from location: URL, response: HTTPURLResponse) throws -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileName = response.suggestedFilename ?? location.lastPathComponent
        let destinationURL = documentsDirectory.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        try fileManager.moveItem(at: location, to: destinationURL)
        return destinationURL
    }
}
