//
//  Configurations.swift
//  Avanta Run
//
//  Created by Daniella Onishi on 30/01/22.
//

import Foundation
import SpriteKit
import UIKit

class Configurations {
    static let shared = Configurations()
    private init() {}
    
    var levelPredefinitions: [Int:LevelData] = [
        1: LevelData(
            levelNumber: 1,
            backgroundName: "",
            levelEnemySpeed: 100
        ),
        2: LevelData(
            levelNumber: 2,
            backgroundName: "",
            levelEnemySpeed: 200
        ),
        3: LevelData(
            levelNumber: 3,
            backgroundName: "",
            levelEnemySpeed: 300
        )
    ]
    
    var levelIndexes: [Int] {
        Array(levelPredefinitions.keys)
    }
}

struct LevelData {
    let levelNumber: Int
    let backgroundName: String
    let levelEnemySpeed: CGFloat
}

