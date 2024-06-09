//
//  URLOpener.swift
//  Osmium
//
//  Created by Francesco on 05/06/24.
//

import UIKit

extension ViewController {
    
    func openURLInSafari(urlString: String) {
        guard let url = URL(string: urlString) else {
            writeToConsole("Invalid URL")
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            self.writeToConsole("Done!")
        }
    }
}
