//
//  AnalyticsService.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 24.11.2023.
//

import YandexMobileMetrica

typealias AnalyticsEventParams = [AnyHashable: Any]

struct DefaultAnalyticsEventParams {
    enum Event: String {
        case open, close, click
    }
    
    enum Screen: String {
        case onboarding = "Onboarding"
        case main = "Main"
        case filters = "Filters"
        case trackerSettings = "Tracker Settings"
        case newTrackerType = "New Tracker Type"
        case categories = "Categories"
        case categoryName = "Category Name"
        case schedule = "Schedule"
        case statistics = "Statistics"
    }
    
    let event: Event
    let screen: Screen
    let item: String?
}

final class AnalyticsService {
    static func sendCustomEvent(event: DefaultAnalyticsEventParams.Event, with params: AnalyticsEventParams) {
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("APPMETRICA REPORT ERROR: \(error.localizedDescription)")
        })
    }
    
    static func sendDefaultEvent(with params: DefaultAnalyticsEventParams) {
        guard params.item != nil || params.event != .click else {
            assertionFailure("Failed to send event: item should be specified in not \"open\" event.")
            return
        }
        
        sendCustomEvent(event: params.event, with: [
            "event": params.event.rawValue,
            "screen": params.screen.rawValue,
            "item": params.item ?? "null"
        ])
    }
    
    static func sendOpenEvent(screen: DefaultAnalyticsEventParams.Screen) {
        sendDefaultEvent(
            with: DefaultAnalyticsEventParams(
                event: .open,
                screen: screen,
                item: nil
            )
        )
    }
    
    static func sendCloseEvent(screen: DefaultAnalyticsEventParams.Screen) {
        sendDefaultEvent(
            with: DefaultAnalyticsEventParams(
                event: .close,
                screen: screen,
                item: nil
            )
        )
    }
    
    static func sendClickEvent(screen: DefaultAnalyticsEventParams.Screen, item: String) {
        sendDefaultEvent(
            with: DefaultAnalyticsEventParams(
                event: .click,
                screen: screen,
                item: item
            )
        )
    }
}
