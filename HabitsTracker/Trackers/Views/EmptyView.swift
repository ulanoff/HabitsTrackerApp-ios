//
//  NoTrakersView.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 13.10.2023.
//

import UIKit

final class EmptyView: UIStackView {
    // MARK: - UI Elements
    private let imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(image: UIImage, text: String) {
        imageView.image = image
        label.text = text
    }
}

// MARK: - Private Methods
private extension EmptyView {
    func setupUI() {
        // MARK: - Subviews
        addArrangedSubview(imageView)
        addArrangedSubview(label)
        
        // MARK: - Views Configuring
        axis = .vertical
        distribution = .equalSpacing
        alignment = .center
        spacing = 8
    }
}
