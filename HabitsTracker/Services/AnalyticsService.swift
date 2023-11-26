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
    
    enum ClickItem: String {
        case track, filter, edit, delete, today, completed, incomplete, habit
        case addTrack = "add_track"
        case allTrackers = "all_trackers"
        case addCategory = "add_category"
        case irregularEvent = "irregular_event"
    }
    
    let event: Event
    let screen: Screen
    let item: ClickItem?
}

final class AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: APIKeys.appMetricaAPIKey)
        else {
            assertionFailure("Failed to configure AppMetrica SDK with API key: \(APIKeys.appMetricaAPIKey)")
            return
        }
        YMMYandexMetrica.activate(with: configuration)
    }
    
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
            "item": params.item?.rawValue ?? "null"
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
    
    static func sendClickEvent(screen: DefaultAnalyticsEventParams.Screen, item: DefaultAnalyticsEventParams.ClickItem) {
        sendDefaultEvent(
            with: DefaultAnalyticsEventParams(
                event: .click,
                screen: screen,
                item: item
            )
        )
    }
}
