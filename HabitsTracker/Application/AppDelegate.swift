//
//  AppDelegate.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.10.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let mockMode = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("Library Directory: ", FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last ?? "Not Found!")
        AnalyticsService.activate()
        
        let userDefaults = UserDefaults.standard
        let coreDataManager = CoreDataManager.shared
        let lastLaunchIsMock = userDefaults.bool(forKey: UserDefaultsKeys.lastLaunchIsMock)
        
        if mockMode || lastLaunchIsMock {
            coreDataManager.clearData()
        }
        
        userDefaults.setValue(mockMode, forKey: UserDefaultsKeys.lastLaunchIsMock)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
