//
//  SharedData.swift
//  WOR - Witch On Rescue
//
//  Created by Daniella Onishi on 08/02/22.
//

import Foundation
import UIKit
import SpriteKit

class SharedData {
    static let shared = SharedData()
    private init () {}
    
    var catsRescued: Int = 0
    var pointsCounter: Int = 0
    
    let pointsListKey = "pointsListKey"
    
    func pickPoints(points: Score) {
        
    }
    
    func savePoints(points: Score) {
        let data = try! JSONEncoder().encode(points)
        UserDefaults.standard.set(data, forKey: points.id)
        
        var list = getPointsListIDs()
        if !list.contains(points.id) {
            list.append(points.id)
            savePointsListIDs(ids: list)
        }
    }
    
    func fetchPoints() -> [Score] {
        let list = getPointsListIDs()
        
        var pointsList: [Score] = []
        
        
        for id in list {
            let point = fetchPoint(id:id)
            if let point = point {
                pointsList.append(point)
            }
        }
        
        return pointsList
        
    }
    
    func fetchPoint(id: String) -> Score? {
        // pega uma gossip dado o ID da gossip
        guard let data = UserDefaults.standard.object(forKey: id) as? Data else { return nil }
        return try?
            JSONDecoder().decode(Score.self, from: data)
    }
    
    private func getPointsListIDs() -> [String] {
        UserDefaults.standard.object(forKey: pointsListKey) as? [String] ?? []
    }
    
    private func savePointsListIDs(ids: [String]) {
        UserDefaults.standard.set(ids, forKey: pointsListKey)
    }
}
