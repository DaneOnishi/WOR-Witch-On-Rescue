//
//  GameScene.swift
//  NanoBusinessMechanics
//
//  Created by Daniella Onishi on 27/01/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var player : SKSpriteNode!
    private var base: SKSpriteNode!
    private var piece: SKSpriteNode!
    private var cameraNode: SKCameraNode!
    private var enemy: SKSpriteNode!
    
    
    private var pieceNames: [String] = ["piece_1", "piece_2", "piece_3"]
    private var pieceSpawnPoint: CGPoint!
    
    private var movingNode: SKSpriteNode?
    private var lastTouchPosition: CGPoint?
    
    private var playerSpeed: CGFloat = 304.23
    private var enemySpeed: CGFloat = 30 // Speed per second
    private var enemySpeedAcceleration: CGFloat = 0.04 // Adds to the enemy spee every tick
    private var enemySpeedAccelerationIncrease: CGFloat = 0.0001 // Adds to the enemy acceleration every tick
    
    private var maxCameraY: CGFloat = 0
    private var spawnPointCameraOffSet: CGFloat = 0
    private var playerCameraOffSet: CGFloat = 0
    
    var createdPieces: CGFloat = 2
    
    private var initialPlayerPosition: CGPoint!
    private var initialCameraPosition: CGPoint!
    private var initialEnemyPosition: CGPoint!
    
    private var initialEnemySpeed: CGFloat!
    private var initialEnemySpeedAcceleration: CGFloat!
    
    // var cameraPosition = player.position
    
    override func didMove(to view: SKView) {
        player = childNode(withName: "player") as? SKSpriteNode
        base = childNode(withName: "base") as? SKSpriteNode
        piece = childNode(withName: "piece") as? SKSpriteNode
        enemy = childNode(withName: "enemy") as? SKSpriteNode
        cameraNode = camera!

        pieceSpawnPoint = piece.position
        spawnPointCameraOffSet = pieceSpawnPoint.y - cameraNode.position.y
        playerCameraOffSet = cameraNode.position.y - player.position.y
        
        maxCameraY = cameraNode.position.y
        
        initialPlayerPosition = player.position
        initialEnemyPosition = enemy.position
        initialCameraPosition = camera?.position
        
        initialEnemySpeed = enemySpeed
        initialEnemySpeedAcceleration = enemySpeedAcceleration
        
        
        animationSetup()
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let node = nodes(at: pos).first {
            if node.name == "player" {
                movingNode = player
            } else if node.name == "piece" {
                print("New moving node: \(piece)")
                movingNode = piece
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let movingNode = movingNode {
            if movingNode.name == "piece" {
                print("New position: \(pos)")
                movingNode.position = pos
            }
            
            lastTouchPosition = pos
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let movingNode = movingNode,
           movingNode.name == "piece",
           children
            .filter({ node in node.name == "base" })
            .contains(where: { node in node.intersects(movingNode) }) {
            movingNode.name = "base"
            movingNode.removeAllActions()
            spawnPiece()
        }
        movingNode = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    func spawnPiece() {
        let newPiece = SKSpriteNode(imageNamed: pieceNames.randomElement()!)
        
        createdPieces += 1
        
        newPiece.zPosition = -createdPieces
        newPiece.position = cameraNode.position + CGPoint(x: 0, y: spawnPointCameraOffSet)
        newPiece.name = "piece"
        newPiece.setScale(0.28)
        
        piece = newPiece
        
        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 20), duration: 0.5)
        moveUp.timingMode = .easeInEaseOut
        
        let moveDown = SKAction.move(by: CGVector(dx: 0, dy: -20), duration: 0.5)
        moveDown.timingMode = .easeInEaseOut
        
        newPiece.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    moveUp,
                    SKAction.wait(forDuration: 0.1),
                    moveDown,
                    SKAction.wait(forDuration: 0.1)
                ])
            )
        )
        
        addChild(newPiece)
    }
    
    func updateCamera(playerPosition: CGPoint) {
        if playerPosition.y + playerCameraOffSet >= maxCameraY {
            self.cameraNode.position.y = playerPosition.y + playerCameraOffSet
            maxCameraY = self.cameraNode.position.y
        }
    }
    
    func movePlayer(lastTouchPosition: CGPoint) {
        let direction = lastTouchPosition - player.position
        let normalized = direction.normalized()
        let newPosition = player.position + (normalized * playerSpeed / 60)
        
        if nodes(at: newPosition).contains(where: { node in node.name == "base" }) {
            player.position = newPosition
            updateCamera(playerPosition: newPosition)
        }
    }
    
    func moveEnemy() {
        let direction = CGPoint(x: 0, y: 1)
        let normalized = direction.normalized()
        let newPosition = enemy.position + (normalized * enemySpeed / 60)
        
        enemy.position = newPosition
    }
    
    func updateEnemySpeed() {
        
        if enemySpeed < playerSpeed {
            enemySpeed += enemySpeedAcceleration
            enemySpeedAcceleration += enemySpeedAccelerationIncrease
        }
        
        print("New speed: \(enemySpeed)")
    }
    
    func checkEnemyHitPlayer() {
        if enemy.intersects(player) {
            resetGame()
        }
    }
    
    func resetGame() {
        maxCameraY = initialCameraPosition.y
        
        player.position = initialPlayerPosition
        enemy.position = initialEnemyPosition
        camera!.position = initialCameraPosition
        
        enemySpeed = initialEnemySpeed
        enemySpeedAcceleration = initialEnemySpeedAcceleration
        
        children.filter { node in
            node.name == "base" && node != base
        }.forEach { node in
            node.removeFromParent()
        }
        
        if let movingNode = movingNode,
           movingNode.name == "piece" {
            piece = nil
            movingNode.removeFromParent()
        }
        
        piece.removeFromParent()
        spawnPiece()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let movingNode = movingNode {
            if movingNode.name == "player",
               let lastTouchPosition = lastTouchPosition {
                movePlayer(lastTouchPosition: lastTouchPosition)
            }
        }
        
        moveEnemy()
        checkEnemyHitPlayer()
        
        updateEnemySpeed()
        
    }
    
    func animationSetup() {
        
        var textures = [SKTexture]()
        
        textures.append(SKTexture(imageNamed: "2"))
        textures.append(SKTexture(imageNamed: "3"))
        textures.append(SKTexture(imageNamed: "2"))
        textures.append(SKTexture(imageNamed: "1"))
        
        let frames = SKAction.animate(with: textures, timePerFrame: 0.1, resize: false, restore: false)
        
        let animation = SKAction.repeatForever(frames)
        
        player.run(animation)
        
    }
}
