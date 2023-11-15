//
//  CategoriesViewModel.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.11.2023.
//

import Foundation

enum CategoryState {
    case standart
    case selected
}

enum CategoriesState {
    case standart
    case empty
}

protocol CategoriesViewModelDelegate: AnyObject {
    func categoriesViewModel(
        _ viewModel: CategoriesViewModel,
        didSelectCategory name: String
    )
}

final class CategoriesViewModel {
    weak var delegate: CategoriesViewModelDelegate?
    private let trackerCategoryStore = TrackerCategoryStore()
    @Observable var selectedCategoryIndex: Int?
    @Observable var oldSelectedCategoryIndex: Int?
    @Observable var categories: [String] {
        didSet {
            updateState()
        }
    }
    @Observable var state: CategoriesState = .standart
    
    init(delegate: CategoriesViewModelDelegate, selectedCategory: String?) {
        self.delegate = delegate
        categories = trackerCategoryStore.getAllCategoriesNames()
        if let selectedCategory {
            selectedCategoryIndex = categories.firstIndex(of: selectedCategory)
        }
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
    
    func didSelectCategoryAt(index: Int) {
        if let oldSelectedCategoryIndex = selectedCategoryIndex {
            selectedCategoryIndex = index
            self.oldSelectedCategoryIndex = oldSelectedCategoryIndex
        } else {
            selectedCategoryIndex = index
        }
        
        self.delegate?.categoriesViewModel(
            self,
            didSelectCategory: categories[index]
        )
    }
    
    func stateForCategoryAtIndex(index: Int) -> CategoryState {
        return if index == selectedCategoryIndex {
            .selected
        } else {
            .standart
        }
    }
    
    func updateState() {
        if categories.isEmpty {
            state = .empty
        } else {
            state = .standart
        }
    }
    
    private func getAllCategories() {
        categories = trackerCategoryStore.getAllCategoriesNames()
    }
}
