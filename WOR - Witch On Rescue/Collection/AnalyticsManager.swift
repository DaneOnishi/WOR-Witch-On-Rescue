//
//  AnalyticsManager.swift
//  WOR - Witch On Rescue
//
//  Created by Daniella Onishi on 07/02/22.
//

import Foundation
import FirebaseAnalytics

class AnalyticsManager {
    static let shared = AnalyticsManager()
    private init () {}
    
    // Cataloga um evento
    func log(event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.asDict)
    }
    
    // Cataloga uma propriedade
    func log(userProperty: AnalyticsUserProperty) {
        Analytics.setUserProperty(userProperty.value, forName: userProperty.name)
    }
}


enum AnalyticsEvent {
    case gameRestart
    case levelUp(Int)
    
    var name: String {
        switch self {
        case .gameRestart:
            return "game_restart"
        case .levelUp:
            return "level_up"
        }
    }
    
    var asDict: [String: NSObject] {
        switch self {
        case .gameRestart:
            return [:]
        case .levelUp(let newLevel):
            return ["new_level": newLevel as NSObject]
        }
    }
}


enum AnalyticsUserProperty {
    case age(Int)
    var name: String {
        switch self {
        case .age:
            return "user_age"
        }
    }
    
    var value: String {
        switch self {
        case .age(let age):
            return age.description
        }
    }
}

