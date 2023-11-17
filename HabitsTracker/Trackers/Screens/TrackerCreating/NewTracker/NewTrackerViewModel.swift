//
//  NewTrackerViewModel.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.11.2023.
//

import UIKit

final class NewTrackerViewModel {
    @Observable private(set) var trackerSettings: TrackerSettings
    @Observable private(set) var trackerCategory: String?
    @Observable private(set) var isValidName: Bool = false
    @Observable private(set) var nameErrorMessage: String?
    let nameMaxLength = 38
    
    init(trackerType: TrackerType) {
        trackerSettings = TrackerSettings(trackerType: trackerType)
    }
    
    func didEnterNewName(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !(trimmedName.isEmpty || trimmedName.isBlank) else {
            nameErrorMessage = nil
            isValidName = false
            return
        }
        
        guard trimmedName.count <= nameMaxLength else {
            let message = NSLocalizedString(
                "trackerSettingsScreen.nameTextField.maxLengthError",
                comment: ""
            )
            nameErrorMessage = message
            isValidName = false
            return
        }
        
        nameErrorMessage = nil
        isValidName = true
        trackerSettings.name = trimmedName
    }
    
    func didUpdateCategory(name: String?) {
        trackerSettings.categoryName = name
        trackerCategory = name
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

extension NewTrackerViewModel: CategoriesViewModelDelegate {
    func categoriesViewModel(_ viewModel: CategoriesViewModel, didSelectCategory name: String) {
        didUpdateCategory(name: name)
    }
}
