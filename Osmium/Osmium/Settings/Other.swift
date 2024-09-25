//
//  Other.swift
//  cobalt
//
//  Created by Francesco on 27/05/24.
//

import UIKit

class Other: UITableViewController {

    @IBOutlet weak var AppearanceControll: UISegmentedControl!
    @IBOutlet weak var FileNameControll: UISegmentedControl!
    @IBOutlet weak var metadata: UISwitch!
    @IBOutlet weak var debug: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        debug.isOn = UserDefaults.standard.bool(forKey: "debugPlease")
        metadata.isOn = UserDefaults.standard.bool(forKey: "disableMetadata")

        let selectedIndexAppearance = UserDefaults.standard.integer(forKey: "selectedIndexAppearance")
        AppearanceControll.selectedSegmentIndex = selectedIndexAppearance
        
        let selectedIndexNameFormat = UserDefaults.standard.integer(forKey: "selectedIndexNameFormat")
        FileNameControll.selectedSegmentIndex = selectedIndexNameFormat

        AppearanceControll.addTarget(self, action: #selector(appearanceControlValueChanged(_:)), for: .valueChanged)
        FileNameControll.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        setAppAppearance()
    }

    @IBAction func switchMeta(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "disableMetadata")
    }
    
    @IBAction func switchDebug(_ sender: UISwitch) {
        let isEnabled = sender.isOn
        UserDefaults.standard.set(isEnabled, forKey: "debugPlease")
        NotificationCenter.default.post(name: Notification.Name("dDebugPlease"), object: nil, userInfo: ["debugPlease": isEnabled])
    }

    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndexNameFormat = sender.selectedSegmentIndex
        var filenamePattern: String

        switch selectedIndexNameFormat {
        case 0:
            filenamePattern = "classic"
        case 1:
            filenamePattern = "basic"
        case 2:
            filenamePattern = "pretty"
        case 3:
            filenamePattern = "nerdy"
        default:
            filenamePattern = "classic"
        }

        UserDefaults.standard.set(selectedIndexNameFormat, forKey: "selectedIndexNameFormat")
        UserDefaults.standard.set(filenamePattern, forKey: "filenameStyle")
    }

    @objc func appearanceControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndexAppearance = sender.selectedSegmentIndex
        UserDefaults.standard.set(selectedIndexAppearance, forKey: "selectedIndexAppearance")
        
        setAppAppearance()
    }
    
    func setAppAppearance() {
        let appearanceMode = UserDefaults.standard.integer(forKey: "selectedIndexAppearance")
        switch appearanceMode {
        case 0: // Auto
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .unspecified
            }
        case 1: // Dark
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
        case 2: // Light
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        default:
            break
        }
    }
}
