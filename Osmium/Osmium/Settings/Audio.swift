//
//  Audio.swift
//  cobalt
//
//  Created by Francesco on 26/05/24.
//

import UIKit

class Audio: UITableViewController {
    
    @IBOutlet weak var formatControll: UISegmentedControl!
    
    @IBOutlet weak var muteaudio: UISwitch!
    @IBOutlet weak var fullaudio: UISwitch!
    @IBOutlet weak var audioonly: UISwitch!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioonly.isOn = UserDefaults.standard.bool(forKey: "isAudioOnly")
        muteaudio.isOn = UserDefaults.standard.bool(forKey: "isAudioMuted")
        fullaudio.isOn = UserDefaults.standard.bool(forKey: "isTTFullAudio")
        
        let selectedIndexFormat = UserDefaults.standard.integer(forKey: "selectedIndexFormat")
        formatControll.selectedSegmentIndex = selectedIndexFormat
        
        formatControll.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    @IBAction func switchMute(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isAudioMuted")
    }
    
    @IBAction func switchFullAudio(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isTTFullAudio")
    }
    
    @IBAction func switchAudio(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isAudioOnly")
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
            aFormat = "best"
        }
        
        UserDefaults.standard.set(selectedIndexFormat, forKey: "selectedIndexFormat")
        UserDefaults.standard.set(aFormat, forKey: "audioFormat")
    }
}
