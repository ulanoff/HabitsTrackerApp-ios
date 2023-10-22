//
//  UIViewController+ext.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 22.10.2023.
//

import UIKit

extension UIViewController {
    func wrappedInNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}
