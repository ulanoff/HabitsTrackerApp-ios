//
//  TrackerSettingsViewModel.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.11.2023.
//

import UIKit

final class TrackerSettingsViewModel {
    @Observable private(set) var trackerSettings: TrackerSettings
    @Observable private(set) var trackerCategory: String?
    @Observable private(set) var isValidName: Bool = false
    @Observable private(set) var nameErrorMessage: String?
    let trackerForEditing: Tracker?
    let trackerRecordsCount: Int?
    let nameMaxLength = 38
    
    var isCreatingNew: Bool { trackerForEditing == nil }
    
    init(trackerType: TrackerType) {
        trackerSettings = TrackerSettings(trackerType: trackerType)
        trackerRecordsCount = nil
        trackerForEditing = nil
    }
    
    init(tracker: Tracker) {
        trackerSettings = TrackerSettings(
            for: tracker, 
            trackerCategoryStore: TrackerCategoryStore()
        )
        isValidName = true
        trackerForEditing = tracker
        trackerRecordsCount = tracker.records
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
    
    func editedTracker() -> Tracker? {
        guard let trackerForEditing else { return nil }
        return trackerForEditing.updated(with: trackerSettings)
    }
    
    func isEmojiSelected(emoji: String) -> Bool { trackerSettings.emoji == emoji }
    func isColorSelected(color: UIColor) -> Bool {
        trackerSettings.color?.isEqual(to: color) ?? false
    }
}

extension TrackerSettingsViewModel: CategoriesViewModelDelegate {
    func categoriesViewModel(_ viewModel: CategoriesViewModel, didSelectCategory name: String) {
        didUpdateCategory(name: name)
    }
}
