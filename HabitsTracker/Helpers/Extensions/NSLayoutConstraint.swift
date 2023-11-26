//
//  NSLayoutConstraint.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 21.10.2023.
//

import UIKit

extension NSLayoutConstraint {
    func prioritized(_ value: Float) -> NSLayoutConstraint {
        let priority = UILayoutPriority(value)
        let constraint = self
        constraint.priority = priority
        return constraint
    }
}
