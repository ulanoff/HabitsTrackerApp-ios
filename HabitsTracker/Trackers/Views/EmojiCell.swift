//
//  EmojiCell.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 26.10.2023.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(emoji: String) {
        emojiLabel.text = emoji
    }
    
    func selected() {
        emojiLabel.backgroundColor = .ypEmojiBackground
    }
    
    func deselected() {
        emojiLabel.backgroundColor = .clear
    }
}

private extension EmojiCell {
    func configure() {
        addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            emojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
