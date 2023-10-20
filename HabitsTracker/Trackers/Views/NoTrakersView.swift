//
//  NoTrakersView.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 13.10.2023.
//

import UIKit

final class NoTrakersView: UIStackView {
    private let imageView = {
        let imageView = UIImageView(image: .noTrackers)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NoTrakersView {
    func configure() {
        addArrangedSubview(imageView)
        addArrangedSubview(label)
        axis = .vertical
        distribution = .equalSpacing
        alignment = .center
        spacing = 8
    }
}
