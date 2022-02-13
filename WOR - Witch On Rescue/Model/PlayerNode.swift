//
//  Player.swift
//  NanoBusinessMechanics
//
//  Created by Daniella Onishi on 27/01/22.
//

import Foundation
import SpriteKit

protocol PlayerNodeDelegate: AnyObject {
    func moveDone()
}

class PlayerNode: SKSpriteNode {
    private var animation: SKAction!
    weak var delegate: PlayerNodeDelegate?
    
    var playerFootPosition: CGPoint {
        position - CGPoint(x: 0, y: size.height/2)
    }
    var playerFootDifference: CGPoint {
        position - playerFootPosition
    }
    var previousPlayerMovements: [CGPoint] = []
    var nextPlayerMovements: [CGPoint] = []
    var isPlayerWalking = false
    let blocksPerSecond: Double = 3
    
    internal init() {
        let texture = SKTexture(imageNamed: "2")
        super.init(texture: texture, color: .clear, size: texture.size())
        name = "player"
        zPosition = 2
        physicsBody = SKPhysicsBody(texture: texture, size: size)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = 1
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 2
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animationSetup() {
        
        var textures = [SKTexture]()
        
        textures.append(SKTexture(imageNamed: "2"))
        textures.append(SKTexture(imageNamed: "3"))
        textures.append(SKTexture(imageNamed: "2"))
        textures.append(SKTexture(imageNamed: "1"))
        
        let frames = SKAction.animate(with: textures, timePerFrame: 0.1, resize: true, restore: false)
        
        animation = SKAction.repeatForever(frames)
        run(animation)
    }
    
    func createNextMoveAction() -> SKAction? {
        guard !nextPlayerMovements.isEmpty else { return nil }
        
        let nextPosition = nextPlayerMovements.removeFirst()
        previousPlayerMovements.append(nextPosition)
        delegate?.moveDone()
        
        let moveAction = SKAction.move(to: nextPosition + playerFootDifference, duration: 1/blocksPerSecond)
        
        return moveAction
    }
    
    func runLoopMoveAction(moveAction: SKAction) {
        run(moveAction) { [weak self] in
            if let nextMoveAction = self?.createNextMoveAction() {
                self?.runLoopMoveAction(moveAction: nextMoveAction)
            } else {
                self?.isPlayerWalking = false
            }
        }
    }
    
    func addPositionsPlayerQueue(positions: [CGPoint]) {
        print("Current position: \(position)")
        
        nextPlayerMovements.append(contentsOf: positions)
        if !isPlayerWalking,
           let moveAction = createNextMoveAction() {
            isPlayerWalking = true
            runLoopMoveAction(moveAction: moveAction)
        }
    }
}
