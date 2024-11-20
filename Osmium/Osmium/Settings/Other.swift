//
//  Other.swift
//  Osmium
//
//  Created by Francesco on 27/05/24.
//

import UIKit

class Other: UITableViewController {
    @IBOutlet weak var AppearanceControll: UISegmentedControl!
    @IBOutlet weak var FileNameButton: UIButton!
    @IBOutlet weak var metadata: UISwitch!
    @IBOutlet weak var debug: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        debug.isOn = UserDefaults.standard.bool(forKey: "debugPlease")
        metadata.isOn = UserDefaults.standard.bool(forKey: "disableMetadata")

        let selectedIndexAppearance = UserDefaults.standard.integer(forKey: "selectedIndexAppearance")
        AppearanceControll.selectedSegmentIndex = selectedIndexAppearance
        
        let selectedIndexNameFormat = UserDefaults.standard.integer(forKey: "selectedIndexNameFormat")
        configureFileNameMenu(selectedIndex: selectedIndexNameFormat)

        AppearanceControll.addTarget(self, action: #selector(appearanceControlValueChanged(_:)), for: .valueChanged)
        
        setAppAppearance()
    }

    func configureFileNameMenu(selectedIndex: Int) {
        let filenameStyles = [
            ("Classic", "classic"),
            ("Basic", "basic"),
            ("Pretty", "pretty"),
            ("Nerdy", "nerdy")
        ]

        let menuChildren = filenameStyles.enumerated().map { (index, style) in
            UIAction(title: style.0, state: index == selectedIndex ? .on : .off) { [weak self] _ in
                self?.updateFilenameStyle(index: index, pattern: style.1)
            }
        }

        let menu = UIMenu(title: "Filename Style", children: menuChildren)
        FileNameButton.menu = menu
        FileNameButton.showsMenuAsPrimaryAction = true
        
        FileNameButton.setTitle(filenameStyles[selectedIndex].0, for: .normal)
    }

    func updateFilenameStyle(index: Int, pattern: String) {
        UserDefaults.standard.set(index, forKey: "selectedIndexNameFormat")
        UserDefaults.standard.set(pattern, forKey: "filenameStyle")
        
        FileNameButton.setTitle(pattern.capitalized, for: .normal)
    }

    @IBAction func switchMeta(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "disableMetadata")
    }
    
    @IBAction func switchDebug(_ sender: UISwitch) {
        let isEnabled = sender.isOn
        UserDefaults.standard.set(isEnabled, forKey: "debugPlease")
        NotificationCenter.default.post(name: Notification.Name("dDebugPlease"), object: nil, userInfo: ["debugPlease": isEnabled])
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
