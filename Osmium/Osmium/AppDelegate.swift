//
//  AppDelegate.swift
//  Osmium
//
//  Created by Francesco on 28/05/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var backgroundCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UserDefaults.standard.register(defaults: ["saveMedia": true])
        UserDefaults.standard.register(defaults: ["twitterGif": true])
        UserDefaults.standard.register(defaults: ["tiktokH265": true])
        UserDefaults.standard.register(defaults: ["isTTFullAudio": true])
        
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        deleteTemporaryDirectory()
    }
    
    func deleteTemporaryDirectory() {
        let fileManager = FileManager.default
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        do {
            let tmpContents = try fileManager.contentsOfDirectory(at: tmpURL, includingPropertiesForKeys: nil, options: [])
            
            for fileURL in tmpContents {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Error clearing tmp folder: \(error.localizedDescription)")
        }
    }
}

