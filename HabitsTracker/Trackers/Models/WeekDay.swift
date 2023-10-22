//
//  WeekDay.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 22.10.2023.
//

import Foundation

enum WeekDay: Int, Comparable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    static var everyday: [WeekDay] {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
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
        get {
            switch self {
            case .monday:
                "Пн"
            case .tuesday:
                "Вт"
            case .wednesday:
                "Ср"
            case .thursday:
                "Чт"
            case .friday:
                "Пт"
            case .saturday:
                "Сб"
            case .sunday:
                "Вс"
            }
        }
    }
}