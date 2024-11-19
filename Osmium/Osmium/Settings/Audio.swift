//
//  Audio.swift
//  Osmium
//
//  Created by Francesco on 26/05/24.
//

import UIKit

class Audio: UITableViewController {
    
    @IBOutlet weak var formatButton: UIButton!
    @IBOutlet weak var bitrateButton: UIButton!
    @IBOutlet weak var downloadModeButton: UIButton!
    
    @IBOutlet weak var fullaudio: UISwitch!
    
    let audioFormats = ["best", "mp3", "ogg", "wav", "opus"]
    let audioBitrates = ["320kb/s", "256kb/s", "128kb/s", "96kb/s", "64kb/s", "8kb/s"]
    let downloadModes = ["auto", "audio", "mute"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFullAudioSwitch()
        setupFormatButton()
        setupBitrateButton()
        setupDownloadModeButton()
    }
    
    func setupFullAudioSwitch() {
        fullaudio.isOn = UserDefaults.standard.bool(forKey: "tiktokFullAudio")
    }
    
    func setupFormatButton() {
        let selectedFormat = UserDefaults.standard.string(forKey: "audioFormat") ?? "mp3"
        formatButton.setTitle(selectedFormat, for: .normal)
        formatButton.menu = createMenu(for: audioFormats, currentValue: selectedFormat) { [weak self] selectedValue in
            UserDefaults.standard.set(selectedValue, forKey: "audioFormat")
            self?.formatButton.setTitle(selectedValue, for: .normal)
        }
        formatButton.showsMenuAsPrimaryAction = true
    }
    
    func setupBitrateButton() {
        let selectedBitrate = UserDefaults.standard.string(forKey: "audioBitrate") ?? "128ks/s"
        bitrateButton.setTitle(selectedBitrate, for: .normal)
        bitrateButton.menu = createMenu(for: audioBitrates, currentValue: selectedBitrate) { [weak self] selectedValue in
            UserDefaults.standard.set(selectedValue, forKey: "audioBitrate")
            self?.bitrateButton.setTitle(selectedValue, for: .normal)
        }
        bitrateButton.showsMenuAsPrimaryAction = true
    }
    
    func setupDownloadModeButton() {
        let selectedMode = UserDefaults.standard.string(forKey: "downloadMode") ?? "auto"
        downloadModeButton.setTitle(selectedMode, for: .normal)
        downloadModeButton.menu = createMenu(for: downloadModes, currentValue: selectedMode) { [weak self] selectedValue in
            UserDefaults.standard.set(selectedValue, forKey: "downloadMode")
            self?.downloadModeButton.setTitle(selectedValue, for: .normal)
        }
        downloadModeButton.showsMenuAsPrimaryAction = true
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
    
    @IBAction func switchFullAudio(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "tiktokFullAudio")
    }
}
