//
//  WeekDay.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 22.10.2023.
//

import Foundation

enum WeekDay: Int, Comparable, CaseIterable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    init?(numberFromSunday: Int) {
        switch numberFromSunday {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: return nil
        }
    }
    
    init?(numberFromMonday: Int) {
        switch numberFromMonday {
        case 1: self = .monday
        case 2: self = .tuesday
        case 3: self = .wednesday
        case 4: self = .thursday
        case 5: self = .friday
        case 6: self = .saturday
        case 7: self = .sunday
        default: return nil
        }
    }
    
    var description: String {
        switch self {
        case .monday:
            NSLocalizedString("weekDay.monday.short", comment: "")
        case .tuesday:
            NSLocalizedString("weekDay.tuesday.short", comment: "")
        case .wednesday:
            NSLocalizedString("weekDay.wednesday.short", comment: "")
        case .thursday:
            NSLocalizedString("weekDay.thursday.short", comment: "")
        case .friday:
            NSLocalizedString("weekDay.friday.short", comment: "")
        case .saturday:
            NSLocalizedString("weekDay.saturday.short", comment: "")
        case .sunday:
            NSLocalizedString("weekDay.sunday.short", comment: "")
            
        }
    }
}
