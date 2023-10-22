//
//  Button.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 20.10.2023.
//

import UIKit

final class Button: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        setTitleColor(.ypWhite, for: .normal)
        backgroundColor = .ypBlack
        layer.cornerRadius = 16
    }
    
    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        if state == .normal {
            super.setTitleColor(color, for: .normal)
            super.setTitleColor(color?.withAlphaComponent(0.5), for: .highlighted)
        }
    }
}
