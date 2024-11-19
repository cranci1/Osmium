//
//  Video.swift
//  Osmium
//
//  Created by Francesco on 26/05/24.
//

import UIKit

class Video: UITableViewController {
    
    @IBOutlet weak var Quality: UIButton!
    @IBOutlet weak var codecButton: UIButton!
    @IBOutlet weak var twitter: UISwitch!
    @IBOutlet weak var tiktok: UISwitch!
    @IBOutlet weak var youtubeHLS: UISwitch!
    
    let choices = ["max", "8k", "4k", "1440p", "1080p", "720p", "480p", "360p", "240p", "144p"]
    let videoCodecs = ["h264", "av1", "vp9"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupQualityButton()
        setupCodecButton()
        setupSwitches()
    }
    
    func setupSwitches() {
        twitter.isOn = UserDefaults.standard.bool(forKey: "twitterGif")
        tiktok.isOn = UserDefaults.standard.bool(forKey: "tiktokH265")
        youtubeHLS.isOn = UserDefaults.standard.bool(forKey: "youtubeHLS")
    }
    
    func setupQualityButton() {
        let selectedQualitu = UserDefaults.standard.string(forKey: "videoQuality") ?? "max"
        Quality.setTitle(selectedQualitu, for: .normal)
        
        Quality.menu = createMenu(for: choices, currentValue: selectedQualitu) { [weak self] selectedValue in
            UserDefaults.standard.set(selectedValue, forKey: "videoQuality")
            self?.Quality.setTitle(selectedValue, for: .normal)
        }
        Quality.showsMenuAsPrimaryAction = true
    }
    
    func setupCodecButton() {
        let selectedCodec = UserDefaults.standard.string(forKey: "youtubeVideoCodec") ?? "h264"
        codecButton.setTitle(selectedCodec, for: .normal)
        
        codecButton.menu = createMenu(for: videoCodecs, currentValue: selectedCodec) { [weak self] selectedValue in
            UserDefaults.standard.set(selectedValue, forKey: "youtubeVideoCodec")
            self?.codecButton.setTitle(selectedValue, for: .normal)
        }
        codecButton.showsMenuAsPrimaryAction = true
    }
    
    func createMenu(for options: [String], currentValue: String, selectionHandler: @escaping (String) -> Void) -> UIMenu {
        let menuChildren = options.map { option in
            UIAction(
                title: option,
                state: option == currentValue ? .on : .off,
                handler: { _ in
                    selectionHandler(option)
                }
            )
        }
        return UIMenu(children: menuChildren)
    }
    
    @IBAction func switchTwitter(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "twitterGif")
    }
    
    @IBAction func switchTikTok(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "tiktokH265")
    }
    
    @IBAction func switchYouTubeHLS(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "youtubeHLS")
    }
}
