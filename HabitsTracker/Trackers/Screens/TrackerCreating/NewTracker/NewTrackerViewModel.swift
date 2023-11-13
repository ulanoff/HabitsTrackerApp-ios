//
//  NewTrackerViewModel.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.11.2023.
//

import UIKit

final class NewTrackerViewModel {
    @Observable private(set) var trackerSettings: TrackerSettings
    @Observable var isValidName: Bool = false
    @Observable var nameErrorMessage: String?
    let nameMaxLength = 38
    
    init(trackerType: TrackerType) {
        trackerSettings = TrackerSettings(trackerType: trackerType)
    }
    
    func didEnterNewName(_ name: String) {
        if name.isEmpty || name.isBlank {
            nameErrorMessage = nil
            isValidName = false
            return
        } else {
            nameErrorMessage = nil
            isValidName = true
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if name.count > nameMaxLength {
            nameErrorMessage = "Ограничение 38 символов"
            isValidName = false
            return
        } else {
            nameErrorMessage = nil
            isValidName = true
        }
        
        trackerSettings.name = trimmedName
    }
    
    func didUpdateCategory(name: String?) {
        trackerSettings.categoryName = name
    }
    
    func didUpdateEmoji(newEmoji: String?) {
        trackerSettings.emoji = newEmoji
    }
    
    func didUpdateColor(newColor: UIColor?) {
        trackerSettings.color = newColor
    }
    
    func didUpdateSchedule(newSchedule: [WeekDay]?) {
        trackerSettings.schedule = newSchedule
    }
}
