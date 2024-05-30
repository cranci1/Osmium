//
//  VideoPlayer.swift
//  Osmium
//
//  Created by Francesco on 29/05/24.
//

import UIKit
import AVKit
import MobileCoreServices

class VideoPlayerViewController: UIViewController, AVPictureInPictureControllerDelegate {
    
    @IBOutlet weak var videoView: UIView!
    
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    var videoURL: URL?
    var pipController: AVPictureInPictureController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func selectVideoButtonPressed(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.movie], asCopy: true)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: nil)
    }
    
    func playVideo() {
        guard let videoURL = videoURL else { return }
        
        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        
        if let playerView = playerViewController?.view {
            playerView.frame = videoView.bounds
            videoView.addSubview(playerView)
        }
        
        player?.play()
        setupAudioSessionForPlayback()
        enablePiP()
    }
    
    func setupAudioSessionForPlayback() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Error setting audio session: \(error.localizedDescription)")
        }
    }
    
    func enablePiP() {
        guard let player = player,
              AVPictureInPictureController.isPictureInPictureSupported()
        else {
            print("PiP is not supported on this device.")
            return
        }
        
        pipController = AVPictureInPictureController(playerLayer: AVPlayerLayer(player: player))
        pipController!.delegate = self
        pipController!.canStartPictureInPictureAutomaticallyFromInline = true
        pipController!.startPictureInPicture()
    }
}

extension VideoPlayerViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        dismiss(animated: true, completion: nil)
        
        videoURL = url
        playVideo()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
}
