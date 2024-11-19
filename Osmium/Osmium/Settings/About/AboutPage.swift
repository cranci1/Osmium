//
//  AboutPage.swift
//  Osmium
//
//  Created by Francesco on 28/05/24.
//

import UIKit

class AboutPage: UITableViewController {
    
    // Outlets for labels
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var buildLabel: UILabel!
    @IBOutlet weak var licenseLabel: UILabel!
    
    // URLs
    let githubURL = "https://github.com/cranci1/Osmium"
    let cobaltRepo = "https://github.com/imputnet/cobalt"
    let fullLicenseURL = "https://github.com/cranci1/Osmium/blob/main/LICENSE"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Version: \(appVersion)"
        } else {
            versionLabel.text = "Version: N/A"
        }
        
        if let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildLabel.text = "Build: \(appBuild)"
        } else {
            buildLabel.text = "Build: N/A"
        }
    }
    
    func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func githubTapped(_ sender: UITapGestureRecognizer) {
        openURL(githubURL)
    }
    
    @IBAction func cobaltRepo(_ sender: UITapGestureRecognizer) {
        openURL(cobaltRepo)
    }
    
    @IBAction func fullLicenseTapped(_ sender: UITapGestureRecognizer) {
        openURL(fullLicenseURL)
    }
}

