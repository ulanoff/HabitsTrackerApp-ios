//
//  TabBarController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.10.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    private enum Tabs: Int {
        case trackers
        case stats
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        tabBar.barTintColor = .ypGray
        tabBar.tintColor = .ypBlue
        tabBar.backgroundColor = .ypWhite
        
        tabBar.layer.borderColor = UIColor.ypGray.cgColor
        tabBar.layer.borderWidth = 1
        tabBar.layer.masksToBounds = false
        
        let trackersViewController = UIViewController()
        let statsViewController = UIViewController()
        
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        let statsNavigationController = UINavigationController(rootViewController: statsViewController)
        
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: .trackersIcon,
            tag: Tabs.trackers.rawValue
        )
        
        statsNavigationController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: .statsIcon,
            tag: Tabs.stats.rawValue
        )
        
        setViewControllers([
            trackersNavigationController,
            statsNavigationController
        ], animated: false)
    }
    
}
