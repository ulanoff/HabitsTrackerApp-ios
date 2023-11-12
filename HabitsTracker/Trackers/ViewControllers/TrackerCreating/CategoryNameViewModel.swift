//
//  CategoryNameViewModel.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.11.2023.
//

import Foundation

final class CategoryNameViewModel {
    @Observable<String> var categoryName: String = ""
    @Observable<Bool> var isNameValid: Bool = false
    
    private let maxLength = 24
    
    func didEnterNewName(_ name: String) {
        if name.isEmpty || name.isBlank {
            isNameValid = false
            return
        } else {
            isNameValid = true
        }
        
        var trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.count > maxLength {
            isNameValid = false
            return
        } else {
            isNameValid = true
        }
        
        categoryName = trimmedName
    }
}
