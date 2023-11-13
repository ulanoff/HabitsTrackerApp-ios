//
//  EmojiCell.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 26.10.2023.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    // MARK: - UI Elements
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
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
    
    // MARK: - Public Methods
    func configure(emoji: String) {
        emojiLabel.text = emoji
    }
    
    func selected() {
        emojiLabel.backgroundColor = .ypSelectedEmojiBackground
    }
    
    func deselected() {
        emojiLabel.backgroundColor = .clear
    }
}

// MARK: - Private Methods
private extension EmojiCell {
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Subviews
        addSubview(emojiLabel)
        // MARK: - Constraints
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            emojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        // MARK: - Views Configuring
    }
}
