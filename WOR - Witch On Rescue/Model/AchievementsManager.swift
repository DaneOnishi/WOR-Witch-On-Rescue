//
//  AchievementsManager.swift
//  WOR - Witch On Rescue
//
//  Created by Daniella Onishi on 04/03/22.
//

import Foundation
import GameKit
import SpriteKit
import UIKit

class AchievementsManager {
    static let shared = AchievementsManager()
    private init (){}
    
    static let achievementsModel: [Achievement] = [
        Achievement(id: "first_run", type: .firstRound, goal: 1),
        Achievement(id: "rescue_cat_49", type: .rescueCat, goal: 7),
        Achievement(id: "rescue_cat_98", type: .rescueCat, goal: 14),
        Achievement(id: "rescue_cat_147", type: .rescueCat, goal: 21)
    ]
    static var achievementsIDs: [String] {
        achievementsModel.map({$0.id})
    }
    var achievements: [GKAchievement] = []
    
    func loadAchievements() {
        // Load the player's active achievements.
        GKAchievement.loadAchievements(completionHandler: { (achievements: [GKAchievement]?, error: Error?) in
            
            // Find an existing achievement.
            let registeredAchievementIDs = achievements?.map({$0.identifier}) ?? []
            let unregisteredAchievementsIDs = AchievementsManager.achievementsIDs.filter({!registeredAchievementIDs.contains($0)})
            
            self.achievements = unregisteredAchievementsIDs.map({GKAchievement(identifier: $0)})
            self.achievements.append(contentsOf: achievements ?? [])
            // Insert code to report the percentage.
            
            if error != nil {
                // Handle the error that occurs.
                print("Error: \(String(describing: error))")
            }
        })
    }
    
    func updateRescuedCats() {
        let achievementsPercentageIncrease = AchievementsManager.achievementsModel
            .filter({$0.type == .rescueCat})
            .map { achievement in
                (id: achievement.id, percentage: 1/Double(achievement.goal ?? 1) * 100)
        }
        
        var achievementToReport: [GKAchievement] = []
        for percentageIncrease in achievementsPercentageIncrease {
            if let achievement = achievements.first(where: {$0.identifier == percentageIncrease.id}){
                achievement.percentComplete += percentageIncrease.percentage
                achievementToReport.append(achievement)
            }
        }
        
        GKAchievement.report(achievementToReport) { error in
            if error != nil {
                    // Handle the error that occurs.
                    print("Error: \(String(describing: error))")
                }
        }
    }
    
    func updatFirstRound() {
        let achievementsPercentageIncrease = AchievementsManager.achievementsModel
            .filter({$0.type == .firstRound})
            .map { achievement in
                (id: achievement.id, percentage: 1/Double(achievement.goal ?? 1) * 100)
        }
        
        var achievementToReport: [GKAchievement] = []
        for percentageIncrease in achievementsPercentageIncrease {
            if let achievement = achievements.first(where: {$0.identifier == percentageIncrease.id}){
                achievement.percentComplete += percentageIncrease.percentage
                achievementToReport.append(achievement)
            }
        }
        
        GKAchievement.report(achievementToReport) { error in
            if error != nil {
                    // Handle the error that occurs.
                    print("Error: \(String(describing: error))")
                }
        }
    }
}

enum AchievementType {
    case firstRound
    case rescueCat
}

class Achievement {
    let id: String
    let type: AchievementType
    let goal: Int?
    
    internal init(id: String, type: AchievementType, goal: Int? = nil) {
        self.id = id
        self.type = type
        self.goal = goal
    }
}
