//
//  String+ext.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 25.10.2023.
//

import Foundation

extension String {
    var isBlank: Bool {
        return allSatisfy({ $0.isWhitespace })
    }
}
