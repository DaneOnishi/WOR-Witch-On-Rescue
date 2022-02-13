//
//  EnemyNode.swift
//  NanoBusinessMechanics
//
//  Created by Daniella Onishi on 28/01/22.
//

import Foundation
import UIKit
import SpriteKit

class EnemyNode: SKSpriteNode, SKPhysicsContactDelegate {
    // think -- delay fog after starting
     var enemySpeed: CGFloat = 28 // Speed per second
     var enemySpeedAcceleration: CGFloat = 0.007 // Adds to the enemy spee every tick
     var enemySpeedAccelerationIncrease: CGFloat = 0.0005 // Adds to the enemy acceleration every tick
     var maxEnemySpeed: CGFloat = 80
    
     var initialEnemySpeed: CGFloat!
     var initialEnemySpeedAcceleration: CGFloat!
    
    
    internal init() {
        let texture = SKTexture(imageNamed: "fog")
        super.init(texture: texture, color: .clear, size: texture.size())
        name = "fog"
        size = CGSize(width: 690, height: 1400)
        zPosition = 100
        physicsBody = SKPhysicsBody(texture: texture, size: size)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = 4
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 3
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveEnemy() {
        let direction = CGPoint(x: 0, y: 1)
        let normalized = direction.normalized()
        let newPosition = position + (normalized * enemySpeed / 60)
        
        position = newPosition
    }
    
    func updateEnemySpeed() {
        if enemySpeed < maxEnemySpeed {
            enemySpeed += enemySpeedAcceleration
            enemySpeedAcceleration += enemySpeedAccelerationIncrease
        }
    }
}
