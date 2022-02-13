//
//  MagicNode.swift
//  WOR - Witch On Rescue
//
//  Created by Daniella Onishi on 13/02/22.
//

import Foundation
import SpriteKit
import UIKit

class MagicNode: SKSpriteNode {
    
    internal init(startingZPosition: CGFloat) {
        super.init(texture: nil, color: .clear, size: .zero)
        
        // Cria um magic_center e coloca
            // Animacao de rotacao
            // zPosition é startingZPosition + 3
        let magicCenter = SKSpriteNode(imageNamed: "magic_center")
        magicCenter.zPosition = startingZPosition + 3
        
        let magicCenterRotate = SKAction.rotate(byAngle: .pi, duration: 5)
        
        magicCenter.run(
            SKAction.repeatForever(
                magicCenterRotate
            )
        )
        
        let magic_1 = SKSpriteNode(imageNamed: "magic_1")
        magic_1.zPosition = startingZPosition + 2
        
        let magic_1Rotate = SKAction.rotate(byAngle: -.pi, duration: 2)
        
        magic_1.run(
            SKAction.repeatForever(magic_1Rotate))
        
        let magic_2 = SKSpriteNode(imageNamed: "magic_2")
        magic_2.zPosition = startingZPosition + 1
        
        let magic_2Rotate = SKAction.rotate(byAngle: .pi, duration: 3)
        
        magic_2.run(
            SKAction.repeatForever(magic_2Rotate))
        
        
        let magic_3 = SKSpriteNode(imageNamed: "magic_3")
        magic_3.zPosition = startingZPosition + 0
        
        let magic_3Rotate = SKAction.rotate(byAngle: -.pi, duration: 4)
        
        magic_3.run(
            SKAction.repeatForever(magic_3Rotate))
        
        addChild(magicCenter)
        addChild(magic_1)
        addChild(magic_2)
        addChild(magic_3)
        
        // Cria um magic_1 e coloca
            // Animacao de rotacao
            // zPosition é startingZPosition + 2
        
        // Cria um magic_2 e coloca
            // Animacao de rotacao
            // zPosition é startingZPosition + 1
        
        // Cria um magic_3 e coloca
            // Animacao de rotacao
            // zPosition é startingZPosition + 0
        
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 4),
            SKAction.scale(to: 1, duration: 3),
        ])))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
