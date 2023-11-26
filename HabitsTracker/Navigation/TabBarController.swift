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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch traitCollection.userInterfaceStyle {
        case .unspecified:
            tabBar.layer.borderColor = UIColor.ypGray.cgColor
        case .light:
            tabBar.layer.borderColor = UIColor.ypGray.cgColor
        case .dark:
            tabBar.layer.borderColor = UIColor.clear.cgColor
        @unknown default:
            fatalError()
        }
    }
    
    private func configure() {
        tabBar.barTintColor = .ypGray
        tabBar.tintColor = .ypBlue
        tabBar.backgroundColor = .ypWhite
        
        switch traitCollection.userInterfaceStyle {
        case .unspecified:
            tabBar.layer.borderColor = UIColor.ypGray.cgColor
        case .light:
            tabBar.layer.borderColor = UIColor.ypGray.cgColor
        case .dark:
            tabBar.layer.borderColor = UIColor.clear.cgColor
        @unknown default:
            fatalError()
        }
        
        tabBar.layer.borderWidth = 1
        tabBar.layer.masksToBounds = false
        
        let trackersViewModel = TrackersViewModel()
        let trackersViewController = TrackersViewController(viewModel: trackersViewModel)
        let statsViewModel = StatisticsViewModel(
            statisticsService: StatisticsService(
                trackerStore: TrackerStore.shared,
                trackerRecordStore: TrackerRecordStore.shared
            )
        )
        let statsViewController = StatisticsViewController(viewModel: statsViewModel)
        
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        let statsNavigationController = UINavigationController(rootViewController: statsViewController)
        
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabBar.trackers", comment: ""),
            image: .trackersIcon,
            tag: Tabs.trackers.rawValue
        )
        
        statsNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabBar.statistics", comment: ""),
            image: .statsIcon,
            tag: Tabs.stats.rawValue
        )
        
        setViewControllers([
            trackersNavigationController,
            statsNavigationController
        ], animated: false)
    }
    
}
