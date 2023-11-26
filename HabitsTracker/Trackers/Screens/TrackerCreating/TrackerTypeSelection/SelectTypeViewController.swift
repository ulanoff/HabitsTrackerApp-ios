//
//  SelectTypeViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 20.10.2023.
//

import UIKit

final class SelectTypeViewController: UIViewController {
    // MARK: - Properties
    weak var newTrackerDelegate: TrackerSettingsViewControllerDelegate?
    
    // MARK: - UI Elements
    private lazy var buttonStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var habitButton: Button = {
        let button = Button()
        let title = NSLocalizedString("trackerTypeScreen.habitButton", comment: "")
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(didTapHabitButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var irregularButton: Button = {
        let button = Button()
        let title = NSLocalizedString("trackerTypeScreen.eventButton", comment: "")
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(didTapIrregularButton(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Event Handlers
    @objc private func didTapHabitButton(_ sender: UIButton) {
        AnalyticsService.sendClickEvent(screen: .newTrackerType, item: "habit")
        let newTrackerVC = TrackerSettingsViewController(trackerType: .habit)
        newTrackerVC.delegate = newTrackerDelegate
        navigationController?.pushViewController(newTrackerVC, animated: true)
    }
    
    @objc private func didTapIrregularButton(_ sender: UIButton) {
        AnalyticsService.sendClickEvent(screen: .newTrackerType, item: "irregular_event")
        let newTrackerVC = TrackerSettingsViewController(trackerType: .irregularEvent)
        newTrackerVC.delegate = newTrackerDelegate
        navigationController?.pushViewController(newTrackerVC, animated: true)
    }
}

// MARK: - Private Methods
private extension SelectTypeViewController {
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Subviews
        view.addSubview(buttonStack)
        buttonStack.addArrangedSubview(habitButton)
        buttonStack.addArrangedSubview(irregularButton)
        
        // MARK: - Constraints
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        irregularButton.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            buttonStack.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        // MARK: - Views Configuring
        view.backgroundColor = .ypWhite
        title = NSLocalizedString("trackerTypeScreen.title", comment: "")
    }
}
