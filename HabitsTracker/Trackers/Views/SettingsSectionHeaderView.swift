//
//  SettingsSectionHeaderView.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 28.10.2023.
//

import UIKit

final class SettingsSectionHeaderView: UICollectionViewCell {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(text: String) {
        label.text = text
    }
}

private extension SettingsSectionHeaderView {
    func configure() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
