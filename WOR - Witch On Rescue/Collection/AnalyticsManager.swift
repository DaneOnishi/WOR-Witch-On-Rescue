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
    case levelStart
    case levelEnd(Int,Bool,Int) // score, viewedad, placed pieces
    case placedPiece(String, Int, Bool) //piece type, attempts until place, rotated
    case screenView(String, String)
    
    var name: String {
        switch self {
        case .levelStart:
            return AnalyticsEventLevelStart
        case .levelEnd:
            return AnalyticsEventLevelEnd
        case .placedPiece:
            return "placed_piece"
        case .screenView:
            return AnalyticsEventScreenView
        }
    }
    
    var asDict: [String: NSObject] {
        switch self {
        case .levelStart:
            return [:]
        case .levelEnd(let score, let viewedAd, let placedPieces):
            return [
                "score": score as NSObject,
                "viewed_ad": viewedAd as NSObject,
                "placed_pieces": placedPieces as NSObject
            ]
        case .placedPiece(let pieceType, let attempts, let rotated):
            return [
                "piece_type": pieceType as NSObject,
                "attempts_to_place": attempts as NSObject,
                "rotated": rotated as NSObject
            ]
        case .screenView(let screenName, let screenClass) :
            return [
                AnalyticsParameterScreenName: screenName as NSObject,
                AnalyticsParameterScreenClass: screenClass
            ]
        }
    }
}


enum AnalyticsUserProperty {
    var name: String {
        return ""
    }
    
    var value: String {
        return ""
    }
}

