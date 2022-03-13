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
    // increase foggy speed according to the points
    // after x points show some you need to run visual feedback
    var enemySpeed: CGFloat = 43 // Speed per second
    var enemySpeedAcceleration: CGFloat = 0.009 / 60 // Adds to the enemy spee every tick
    var enemySpeedAccelerationIncrease: CGFloat = 0.0023 / 60 // Adds to the enemy acceleration every tick
    var maxEnemySpeed: CGFloat = 90
    var maxEnemySpeedAcceleration: CGFloat = 7 / 60
    
    
    var initialEnemySpeed: CGFloat!
    var initialEnemySpeedAcceleration: CGFloat!
    
    static var textureMap: [String: SKTexture] = [
        "enemy_1": SKTexture(imageNamed: "enemy_1"),
        "enemy_2": SKTexture(imageNamed: "enemy_2"),
        "enemy_3": SKTexture(imageNamed: "enemy_3"),
        "enemy_4": SKTexture(imageNamed: "enemy_4")
    ]
    
    
    internal init() {
        
        super.init(texture: nil, color: .clear, size: .zero)
        name = "fog"
        size = CGSize(width: 690, height: 1400)
        zPosition = 100
        
        
        let enemy_1 = SKSpriteNode(texture: EnemyNode.textureMap["enemy_1"])
        let enemy_2 = SKSpriteNode(texture: EnemyNode.textureMap["enemy_2"])
        let enemy_3 = SKSpriteNode(texture: EnemyNode.textureMap["enemy_3"])
        let enemy_4 = SKSpriteNode(texture: EnemyNode.textureMap["enemy_4"])
        
        enemy_1.zPosition = 6
        enemy_1.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.move(by: CGVector(dx: 20, dy: 0), duration: 1),
                        SKAction.scaleX(to: 0.98, duration: 1)
                    ]),
                    SKAction.group([
                        SKAction.move(by: CGVector(dx: -20, dy: 0), duration: 1),
                        SKAction.scaleX(to: 1.02, duration: 1)
                    ])
                ])
            )
        )
        
      
        enemy_2.zPosition = 7
        
        enemy_2.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.move(by: CGVector(dx: 20, dy: 5), duration: 0.6),
                        SKAction.scaleX(to: 0.995, duration: 0.6)
                    ]),
                    SKAction.group([
                        SKAction.move(by: CGVector(dx: -20, dy: -5), duration: 0.6),
                        SKAction.scaleX(to: 1.01, duration: 0.6)
                    ])
                ])
            )
        )
        
 
        enemy_3.zPosition = 8
        
        enemy_3.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.move(by: CGVector(dx: 15, dy: 0), duration: 1.2),
                        SKAction.scaleX(to: 0.99, duration: 1.2)
                    ]),
                    SKAction.group([
                        SKAction.move(by: CGVector(dx: -15, dy: 0), duration: 1.2),
                        SKAction.scaleX(to: 1.02, duration: 1.2)
                    ])
                ])
            )
        )

        
        
        enemy_4.zPosition = 9
        
        enemy_4.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.move(by: CGVector(dx: 10, dy: 0), duration: 1.5),
                        SKAction.scaleX(to: 0.98, duration: 1.5)
                    ]),
                    SKAction.group([
                        SKAction.move(by: CGVector(dx: -10, dy: 0), duration: 1.5),
                        SKAction.scaleX(to: 1.02, duration: 1.5)
                    ])
                ])
            )
        )
        
        enemy_1.position = enemy_1.position - CGPoint(x: 0, y: 190)
        enemy_2.position = enemy_2.position - CGPoint(x: 0, y: 190)
        enemy_3.position = enemy_3.position - CGPoint(x: 0, y: 190)
        enemy_4.position = enemy_4.position - CGPoint(x: 0, y: 190)
        
        enemy_1.alpha = 0.7
        enemy_2.alpha = 0.7
        enemy_3.alpha = 0.7
        enemy_4.alpha = 0.7
        
        addChild(enemy_1)
        addChild(enemy_2)
        addChild(enemy_3)
        addChild(enemy_4)
        
        physicsBody = SKPhysicsBody(rectangleOf: enemy_1.size, center: CGPoint(x: 0, y: -310))
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = 4
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 3
//        run(SKAction.repeatForever(SKAction.sequence([
//            SKAction.scaleX(to: 1.3, duration: 4),
//            SKAction.scaleX(to: 1, duration: 3),
//        ])))
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
        enemySpeed += enemySpeedAcceleration
        if enemySpeed > maxEnemySpeed {
            enemySpeed = maxEnemySpeed
        }
        if enemySpeedAcceleration > maxEnemySpeedAcceleration {
            enemySpeedAcceleration = maxEnemySpeedAcceleration
        }
    }
}

