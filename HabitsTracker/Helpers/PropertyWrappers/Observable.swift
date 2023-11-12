//
//  Observable.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.11.2023.
//

import Foundation

@propertyWrapper
final class Observable<T> {
    private var observers: [() -> Void] = []
    
    var wrappedValue: T {
        didSet {
            observers.forEach { $0() }
        }
    }
    
    var projectedValue: Observable<T> { self }
    
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    func bind(observer: @escaping () -> Void) {
        observer()
        observers.append(observer)
    }
}
