//
//  StatisticsView.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 21.11.2023.
//

import UIKit

final class StatisticsView: UIView {
    // MARK: - UI Elements
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let colors = [
            UIColor(hex: "#007BFA"),
            UIColor(hex: "#46E69D"),
            UIColor(hex: "#FD4C49"),
        ]
        addGradientBorder(colors: colors, orientation: .horizontal, width: 3, cornerRadius: 16)
    }
    
    // MARK: - Public Methods
    func configure(name: String, value: Int) {
        valueLabel.text = String(value)
        nameLabel.text = name
    }
    
    func updateValue(value: Int) {
        valueLabel.text = String(value)
    }
}

// MARK: - Private Methods
private extension StatisticsView {
    func setupUI() {
        // MARK: - Subviews
        addSubview(valueLabel)
        addSubview(nameLabel)
        
        // MARK: - Constraints
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            
            nameLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
        
        // MARK: - View Configuring
        layer.cornerRadius = 16
        clipsToBounds = true
    }
}

