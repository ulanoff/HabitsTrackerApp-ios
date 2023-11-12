//
//  OnboardingPageViewController.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.11.2023.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    // MARK: - Lifecycle
    init(text: String, backgroundImage: UIImage) {
        super.init(nibName: nil, bundle: nil)
        textLabel.text = text
        backgroundImageView.image = backgroundImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Private Methods
private extension OnboardingPageViewController {
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Subviews
        view.addSubview(backgroundImageView)
        view.addSubview(textLabel)
        
        // MARK: - Constraints
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            textLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            textLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -270)
        ])
        
        // MARK: - Views Configuring
        view.backgroundColor = .ypWhite
    }
}
