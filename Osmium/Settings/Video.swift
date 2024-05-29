//
//  Video.swift
//  cobalt
//
//  Created by Francesco on 26/05/24.
//

import UIKit

class Video: UITableViewController {
    
    @IBOutlet weak var Quality: UIButton!
    
    var isPresentingActionSheet = false
    var selectedQualityIndex = 4
    let choices = ["8k+", "4k", "1440p", "1080p", "720p", "480p", "360p", "240p", "144p"]
    
    @IBOutlet weak var codecControll: UISegmentedControl!
    
    @IBOutlet weak var twitter: UISwitch!
    @IBOutlet weak var tiktok: UISwitch!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedQualityIndex = UserDefaults.standard.integer(forKey: "SelectedChoiceIndex")
        
        twitter.isOn = UserDefaults.standard.bool(forKey: "twitterGif")
        tiktok.isOn = UserDefaults.standard.bool(forKey: "tiktokH265")
        
        let selectedIndexCodec = UserDefaults.standard.integer(forKey: "selectedIndexCodec")
        codecControll.selectedSegmentIndex = selectedIndexCodec
        
        codecControll.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        updateButtonTitle()
    }
    
    @IBAction func switchTwitter(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "twitterGif")
    }
    
    @IBAction func switchTikTok(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "tiktokH265")
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndexCodec = sender.selectedSegmentIndex
        var vCodec: String
        
        switch selectedIndexCodec {
        case 0:
            vCodec = "h264"
        case 1:
            vCodec = "av1"
        case 2:
            vCodec = "vp9"
        default:
            vCodec = "h264"
        }
        
        UserDefaults.standard.set(selectedIndexCodec, forKey: "selectedIndexCodec")
        UserDefaults.standard.set(vCodec, forKey: "vCodec")
    }
    
    @IBAction func presentActionSheet(_ sender: UIButton) {
         isPresentingActionSheet = true
         presentChoicesActionSheet()
     }
     
     func presentChoicesActionSheet() {
         let actionSheet = UIAlertController(title: "Choose Quality", message: nil, preferredStyle: .actionSheet)
         
         for (index, choice) in choices.enumerated() {
             actionSheet.addAction(UIAlertAction(title: choice, style: .default, handler: { _ in
                 self.updateSelectedChoiceIndex(index)
             }))
         }
         
         actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
         
         present(actionSheet, animated: true, completion: nil)
     }
     
     func updateSelectedChoiceIndex(_ index: Int) {
         selectedQualityIndex = index
         updateButtonTitle()
         UserDefaults.standard.set(selectedQualityIndex, forKey: "SelectedChoiceIndex")
         NotificationCenter.default.post(name: Notification.Name("SelectedChoiceChanged"), object: selectedQualityIndex)
     }
     
     func updateButtonTitle() {
         let selectedChoice = choices[selectedQualityIndex]
         Quality.setTitle(selectedChoice, for: .normal)
     }
}
