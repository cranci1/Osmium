//
//  VideoPlayer.swift
//  Osmium
//
//  Created by Francesco on 29/05/24.
//

import UIKit
import AVKit

class VideoPlayerViewController: UIViewController, AVPictureInPictureControllerDelegate {
    
    @IBOutlet weak var videoView: UIView!
    
    private var player: AVPlayer?
    private var playerViewController: AVPlayerViewController?
    private var videoURL: URL?
    private var pipController: AVPictureInPictureController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func selectVideoButtonPressed(_ sender: UIButton) {
        presentMediaSelectionActionSheet()
    }
    
    private func presentMediaSelectionActionSheet() {
        let alertController = UIAlertController(title: "Select Media", message: "Choose a source to select a video. AV1 and VP9 are not supported yet.", preferredStyle: .actionSheet)
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.presentImagePicker()
        }
        galleryAction.setValue(UIImage(systemName: "photo.on.rectangle"), forKey: "image")
        
        let documentAction = UIAlertAction(title: "Documents", style: .default) { _ in
            self.presentDocumentPicker()
        }
        documentAction.setValue(UIImage(systemName: "doc"), forKey: "image")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(galleryAction)
        alertController.addAction(documentAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func presentImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            showAlert(title: "Error", message: "Photo Library is not available.")
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    private func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.movie], asCopy: true)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true)
    }
    
    private func playVideo() {
        guard let videoURL = videoURL else { return }
        
        let asset = AVURLAsset(url: videoURL)
        let playableKey = "playable"
        
        asset.loadValuesAsynchronously(forKeys: [playableKey]) {
            DispatchQueue.main.async {
                self.handleAssetLoading(asset: asset, key: playableKey)
            }
        }
    }
    
    private func handleAssetLoading(asset: AVURLAsset, key: String) {
        var error: NSError?
        let status = asset.statusOfValue(forKey: key, error: &error)
        
        switch status {
        case .loaded:
            setupPlayer(with: asset)
        case .failed:
            showAlert(title: "Error", message: "Failed to load video: \(error?.localizedDescription ?? "Unknown Error")")
        default:
            showAlert(title: "Error", message: "Unknown status")
        }
    }
    
    private func setupPlayer(with asset: AVURLAsset) {
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        if playerViewController == nil {
            playerViewController = AVPlayerViewController()
        }
        
        playerViewController?.player = player
        
        if let playerView = playerViewController?.view {
            playerView.frame = videoView.bounds
            videoView.addSubview(playerView)
        }
        
        player?.play()
        setupAudioSessionForPlayback()
        enablePiP()
    }
    
    private func setupAudioSessionForPlayback() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            showAlert(title: "Error", message: "Error setting audio session: \(error.localizedDescription)")
        }
    }
    
    private func enablePiP() {
        guard let player = player, AVPictureInPictureController.isPictureInPictureSupported() else {
            print("PiP is not supported on this device.")
            return
        }
        
        pipController = AVPictureInPictureController(playerLayer: AVPlayerLayer(player: player))
        pipController?.delegate = self
        pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        pipController?.startPictureInPicture()
    }
    
    func replaceCurrentVideo(with url: URL) {
        playerViewController?.willMove(toParent: nil)
        playerViewController?.view.removeFromSuperview()
        playerViewController?.removeFromParent()
        player?.pause()
        player = nil
        
        videoURL = url
        playVideo()
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
