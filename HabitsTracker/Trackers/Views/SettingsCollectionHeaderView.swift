//
//  SettingsCollectionHeaderView.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 28.10.2023.
//

import UIKit

final class SettingsCollectionHeaderView: UICollectionViewCell {
    // MARK: - UI Elements
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Event Handlers
    // MARK: - Public Methods
    func configure(withText text: String) {
        label.text = text
    }
}

// MARK: - Private Methods
private extension SettingsCollectionHeaderView {
    func setupUI() {
        // MARK: - Subviews
        addSubview(label)
        
        // MARK: - Constraints
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        // MARK: - Views Configuring
    }
}
