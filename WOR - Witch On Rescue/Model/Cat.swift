//
//  Cat.swift
//  WOR - Witch On Rescue
//
//  Created by Daniella Onishi on 06/02/22.
//

import Foundation
import SpriteKit
import UIKit

class CatNode: SKSpriteNode {
    internal init() {
        let texture = SKTexture(imageNamed: "cat")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.size = size
        physicsBody = SKPhysicsBody(circleOfRadius: 30)
        physicsBody?.categoryBitMask = 2
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 1
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.isDynamic = true
        setScale(0.6)
        name = "cat"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


