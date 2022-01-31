//
//  Player.swift
//  NanoBusinessMechanics
//
//  Created by Daniella Onishi on 27/01/22.
//

import Foundation
import SpriteKit

class Player {
    private var node: SKSpriteNode
    private var animation: SKAction!
    
    init(node: SKSpriteNode) {
        self.node = node
    }
    
    func animationSetup() {
        
        var textures = [SKTexture]()
        
        textures.append(SKTexture(imageNamed: "2"))
        textures.append(SKTexture(imageNamed: "3"))
        textures.append(SKTexture(imageNamed: "2"))
        textures.append(SKTexture(imageNamed: "1"))
        
        let frames = SKAction.animate(with: textures, timePerFrame: 0.1, resize: false, restore: false)
        
        animation = SKAction.repeatForever(frames)
        
        node.run(animation)
        
    }
}
