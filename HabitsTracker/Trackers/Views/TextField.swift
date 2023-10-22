//
//  TextField.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 21.10.2023.
//

import UIKit

final class TextField: UITextField {
    private let padding = UIEdgeInsets(top: 26, left: 16, bottom: 26, right: 16)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .ypBackground
        textColor = .ypBlack
        font = .systemFont(ofSize: 17)
        layer.masksToBounds = true
        layer.cornerRadius = 16
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
}

