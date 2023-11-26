//
//  FilterOperation.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 18.11.2023.
//

import Foundation

enum FilterOperation: CaseIterable {
    case byWeekday
    case byToday
    case byCompleteness
    case byNotCompleteness
    case search
    
    var description: String {
        switch self {
        case .byWeekday:
            NSLocalizedString("filter.byWeekday", comment: "")
        case .byToday:
            NSLocalizedString("filter.byToday", comment: "")
        case .byCompleteness:
            NSLocalizedString("filter.byCompleteness", comment: "")
        case .byNotCompleteness:
            NSLocalizedString("filter.byNotCompleteness", comment: "")
        case .search:
            NSLocalizedString("filter.search", comment: "")
        }
    }
}
