//
//  MediaClass.swift
//  Osmium
//
//  Created by Francesco on 29/05/24.
//

import UIKit
import AVKit
import MobileCoreServices

class VideoPlayerViewController: UIViewController, UIDocumentPickerDelegate {

    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    var videoURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func selectVideoButtonPressed(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.movie], asCopy: true)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        dismiss(animated: true, completion: nil)

        videoURL = url
        playVideo()
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }

    func playVideo() {
        guard let videoURL = videoURL else { return }

        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)

        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        present(playerViewController!, animated: true) {
            self.player?.play()
            self.setupAudioSessionForPlayback()
            self.enablePiP()
        }
    }

    func setupAudioSessionForPlayback() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting audio session: \(error.localizedDescription)")
        }
    }

    func enablePiP() {
        guard let playerViewController = playerViewController else { return }
        guard let player = playerViewController.player else { return }

        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("PiP is not supported on this device.")
            return

            let pipController = AVPictureInPictureController(playerLayer: AVPlayerLayer(player: player))
            pipController!.delegate = self
            pipController!.canStartPictureInPictureAutomaticallyFromInline = true
            pipController!.startPictureInPicture()
            self.pipController = pipController
        }
    }

    var pipController: AVPictureInPictureController?
}

extension VideoPlayerViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP started")
    }

    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will stop")
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP stopped")
    }
}
