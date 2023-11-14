//
//  CategoryNameViewModel.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.11.2023.
//

import Foundation

final class CategoryNameViewModel {
    @Observable var categoryName: String = ""
    @Observable var isNameValid: Bool = false
    
    private let maxLength = 24
    
    func didEnterNewName(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard 
            !(trimmedName.isEmpty || trimmedName.isBlank),
            trimmedName.count <= maxLength
        else {
            isNameValid = false
            return
        }
        
        isNameValid = true
        categoryName = trimmedName
    }
}
