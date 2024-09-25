//
//  Audio.swift
//  cobalt
//
//  Created by Francesco on 26/05/24.
//

import UIKit

class Audio: UITableViewController {
    
    @IBOutlet weak var formatControll: UISegmentedControl!
    @IBOutlet weak var bitrateControll: UISegmentedControl!
    @IBOutlet weak var downloadModeControll: UISegmentedControl!
    
    @IBOutlet weak var fullaudio: UISwitch!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        fullaudio.isOn = UserDefaults.standard.bool(forKey: "tiktokFullAudio")
        
        let selectedIndexFormat = UserDefaults.standard.integer(forKey: "selectedIndexFormat")
        formatControll.selectedSegmentIndex = selectedIndexFormat
        formatControll.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        let selectedIndexBitrate = UserDefaults.standard.integer(forKey: "selectedIndexBitrate")
        bitrateControll.selectedSegmentIndex = selectedIndexBitrate
        bitrateControll.addTarget(self, action: #selector(bitrateSegmentedControlValueChanged(_:)), for: .valueChanged)
        
        let selectedIndexMode = UserDefaults.standard.integer(forKey: "selectedIndexMode")
        downloadModeControll.selectedSegmentIndex = selectedIndexMode
        downloadModeControll.addTarget(self, action: #selector(downloadModeSegmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    @IBAction func switchFullAudio(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "tiktokFullAudio")
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndexFormat = sender.selectedSegmentIndex
        var aFormat: String
        
        switch selectedIndexFormat {
        case 0:
            aFormat = "best"
        case 1:
            aFormat = "mp3"
        case 2:
            aFormat = "ogg"
        case 3:
            aFormat = "wav"
        case 4:
            aFormat = "opus"
        default:
            aFormat = "mp3"
        }
        
        UserDefaults.standard.set(selectedIndexFormat, forKey: "selectedIndexFormat")
        UserDefaults.standard.set(aFormat, forKey: "audioFormat")
    }
    
    @objc func bitrateSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndexBitrate = sender.selectedSegmentIndex
        var bitRate: String
        
        switch selectedIndexBitrate {
        case 0:
            bitRate = "320"
        case 1:
            bitRate = "256"
        case 2:
            bitRate = "128"
        case 3:
            bitRate = "96"
        case 4:
            bitRate = "64"
        case 5:
            bitRate = "8"
        default:
            bitRate = "128"
        }
        
        UserDefaults.standard.set(selectedIndexBitrate, forKey: "selectedIndexBitrate")
        UserDefaults.standard.set(bitRate, forKey: "audioBitrate")
    }
    
    @objc func downloadModeSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndexMode = sender.selectedSegmentIndex
        var mode: String
        
        switch selectedIndexMode {
        case 0:
            mode = "auto"
        case 1:
            mode = "audio"
        case 2:
            mode = "mute"
        default:
            mode = "auto"
        }
        
        UserDefaults.standard.set(selectedIndexMode, forKey: "selectedIndexMode")
        UserDefaults.standard.set(mode, forKey: "downloadMode")
    }
}
