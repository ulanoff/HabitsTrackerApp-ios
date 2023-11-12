//
//  CategoriesViewModel.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.11.2023.
//

import Foundation

final class CategoriesViewModel {
    private let trackerCategoryStore = TrackerCategoryStore()
    
    @Observable<[String]> var categories: [String]
    
    init() {
        categories = trackerCategoryStore.getAllCategoriesNames()
    }
    
    func didDeleteCategory(_ category: TrackerCategory) {
        trackerCategoryStore.deleteCategory(category)
        getAllCategories()
    }
    
    func didUpdateCategory(_ category: TrackerCategory, newCategory: TrackerCategory) {
        trackerCategoryStore.updateCategoryInfo(category, to: newCategory)
        getAllCategories()
    }
    
    func didAddCategory(_ category: TrackerCategory) {
        _ = trackerCategoryStore.createCategory(category)
        getAllCategories()
    }
    
    private func getAllCategories() {
        categories = trackerCategoryStore.getAllCategoriesNames()
    }
}
