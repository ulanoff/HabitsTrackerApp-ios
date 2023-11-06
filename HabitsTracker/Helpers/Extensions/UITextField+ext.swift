//
//  UITextField+ext.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 23.10.2023.
//

import UIKit

extension UITextField {
    func setCustomClearButtonWithText(_ text: String) {
        clearButtonMode = .never
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.addTarget(self, action: #selector(UITextField.clear), for: .touchUpInside)
        rightView = button
        rightViewMode = .whileEditing
    }
    
    @objc func clear() {
        if let result = delegate?.textFieldShouldClear?(self),
        result == true {
            text = ""
        }
    }
}
