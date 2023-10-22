//
//  UITableViewCell+ext.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 21.10.2023.
//

import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
