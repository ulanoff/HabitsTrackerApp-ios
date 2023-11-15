//
//  OnboardingViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.11.2023.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    // MARK: - Properties
    private lazy var pages: [OnboardingPageViewController] = {
        let page1 = OnboardingPageViewController(
            text: "Отслеживайте только то, что хотите",
            backgroundImage: .onboarding1
        )
        let page2 = OnboardingPageViewController(
            text: "Даже если это не литры воды и йога",
            backgroundImage: .onboarding2
        )
        return [page1, page2]
    }()
    
    // MARK: - UI Elements
    private lazy var button: Button = {
        let button = Button()
        button.setTitle("Вот это технологии!", for: .normal)
        button.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.numberOfPages = pages.count
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray
        return pageControl
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        dataSource = self
        delegate = self
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: true)
        }
    }
    
    // MARK: - Event Handlers
    @objc private func didTapContinueButton() {
        changeIsFirstLaunchToFalse()
        showMainScreen()
    }
}

// MARK: - Private Methods
private extension OnboardingViewController {
    func showMainScreen() {
        guard let window = UIApplication.shared.windows.first
        else {
            assertionFailure("Failed to get key window")
            return
        }
        
        let tabBarController = TabBarController()
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromTop
        
        window.layer.add(transition, forKey: kCATransition)
        window.rootViewController = tabBarController
    }
    
    func changeIsFirstLaunchToFalse() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(true, forKey: UserDefaultsKeys.launchedBefore)
    }
    
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Subviews
        view.addSubview(button)
        view.addSubview(pageControl)
        
        // MARK: - Constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -50),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24)
        ])
        
        // MARK: - Views Configuring
        view.backgroundColor = .ypWhite
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        guard 
            let currentPage = viewController as? OnboardingPageViewController,
            let currentIndex = pages.firstIndex(of: currentPage)
        else {
            return nil
        }
        
        let prevIndex = currentIndex - 1
        
        if prevIndex >= 0 {
            return pages[prevIndex]
        } else {
            return pages.last
        }
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard
            let currentPage = viewController as? OnboardingPageViewController,
            let currentIndex = pages.firstIndex(of: currentPage)
        else {
            return nil
        }
        
        let nextIndex = currentIndex + 1
        
        if nextIndex < pages.count {
            return pages[nextIndex]
        } else {
            return pages.first
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let currentPage = pageViewController.viewControllers?.first as? OnboardingPageViewController,
            let currentIndex = pages.firstIndex(of: currentPage)
        else {
            return
        }
        
        pageControl.currentPage = currentIndex
    }
}
