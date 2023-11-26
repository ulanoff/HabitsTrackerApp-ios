//
//  ColorCell.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 28.10.2023.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    // MARK: - Properties
    private var color: UIColor = .clear
    private var outlineColor: UIColor = .clear
    private let outlineWidth: CGFloat = 3
    
    // MARK: - UI Elements
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var outlineView: UIView = {
        let view = UIView()
        view.layer.borderWidth = outlineWidth
        view.layer.borderColor = outlineColor.cgColor
        view.layer.cornerRadius = 12
        return view
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
    func setup(color: UIColor) {
        self.color = color
        self.outlineColor = color.withAlphaComponent(0.25)
        colorView.backgroundColor = color
    }
    
    func selected() {
        outlineView.layer.borderColor = outlineColor.cgColor
    }
    
    func deselected() {
        outlineView.layer.borderColor = UIColor.clear.cgColor
    }
}

// MARK: - Private Methods
private extension ColorCell {
    // MARK: - Setup UI
    func setupUI() {
        // MARK: - Subviews
        addSubview(outlineView)
        outlineView.addSubview(colorView)
        
        // MARK: - Constraints
        colorView.translatesAutoresizingMaskIntoConstraints = false
        outlineView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding = outlineWidth * 2
        NSLayoutConstraint.activate([
            outlineView.topAnchor.constraint(equalTo: topAnchor),
            outlineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            outlineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            outlineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            colorView.topAnchor.constraint(equalTo: outlineView.topAnchor, constant: padding),
            colorView.leadingAnchor.constraint(equalTo: outlineView.leadingAnchor, constant: padding),
            colorView.bottomAnchor.constraint(equalTo: outlineView.bottomAnchor, constant: -padding),
            colorView.trailingAnchor.constraint(equalTo: outlineView.trailingAnchor, constant: -padding)
        ])
        // MARK: - Views Configuring
    }
}
