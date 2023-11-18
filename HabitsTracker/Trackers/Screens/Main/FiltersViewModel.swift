//
//  FiltersViewModel.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 18.11.2023.
//

import Foundation


enum FilterState {
    case standart
    case selected
}

protocol FiltersViewModelDelegate: AnyObject {
    func filtersViewModel(_ viewModel: FiltersViewModel, didSelectFilter filter: FilterOperation)
}

final class FiltersViewModel {
    weak var delegate: FiltersViewModelDelegate?
    private var selectedFilter: FilterOperation
    let filters: [FilterOperation] = [.byWeekday, .byToday, .byCompleteness, .byNotCompleteness]
    
    @Observable var selectedFilterIndex: Int = 0
    @Observable var oldSelectedFilterIndex: Int = 0
    
    init(delegate: FiltersViewModelDelegate, selectedFilter: FilterOperation?) {
        self.delegate = delegate
        if let selectedFilter {
            self.selectedFilter = selectedFilter
            selectedFilterIndex = filters.firstIndex(of: selectedFilter) ?? 0
            oldSelectedFilterIndex = filters.firstIndex(of: selectedFilter) ?? 0
        } else {
            self.selectedFilter = .byWeekday
        }
    }
    
    func stateForFilterAt(index: Int) -> FilterState {
        index == selectedFilterIndex ? .selected : .standart
    }
    
    func didSelectFilterAt(index: Int) {
        let oldSelectedFilterIndex = selectedFilterIndex
        selectedFilterIndex = index
        self.oldSelectedFilterIndex = oldSelectedFilterIndex
        
        delegate?.filtersViewModel(self, didSelectFilter: filters[index])
    }
}
