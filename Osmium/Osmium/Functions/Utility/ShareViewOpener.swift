//
//  ShareViewOpener.swift
//  Osmium
//
//  Created by Francesco on 06/06/24.
//

import UIKit

extension ViewController {
    
    func openShareView(with fileURL: URL) {
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}
