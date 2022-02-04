//
//  GameScene.swift
//  NanoBusinessMechanics
//
//  Created by Daniella Onishi on 27/01/22.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    
    private var player : SKSpriteNode!
    
    private var cameraNode: SKCameraNode!
    
    private var enemy: SKSpriteNode!
    
    private var cat: SKSpriteNode!
    private var potion: SKSpriteNode!
    
    private var pieceNames: [String] = ["piece_1", "piece_2", "piece_3"]
    private var pieceSpawnPoint: CGPoint!
    private var catSpawnPoint: CGPoint!
    
    
    
    private var movingNode: SKNode?
    private var lastTouchPosition: CGPoint?
    
    private var playerSpeed: CGFloat = 304.23
    private var enemySpeed: CGFloat = 30 // Speed per second
    private var enemySpeedAcceleration: CGFloat = 0.04 // Adds to the enemy spee every tick
    private var enemySpeedAccelerationIncrease: CGFloat = 0.0001 // Adds to the enemy acceleration every tick
    
    private var maxCameraY: CGFloat = 0
    private var spawnPointCameraOffSet: CGFloat = 0
    private var playerCameraOffSet: CGFloat = 0
    
    var createdPieces: CGFloat = 2
    var catsRescued = 0
    var pointsCounter: Int = 0
    
    private var initialPlayerPosition: CGPoint!
    private var initialCameraPosition: CGPoint!
    private var initialEnemyPosition: CGPoint!
    
    private var initialEnemySpeed: CGFloat!
    private var initialEnemySpeedAcceleration: CGFloat!
    private var pieceNode: PieceNode!
    
    private var gameCenterManager: GameCenterManager!
    
    // TODO: Move to player later...
    var playerFootPosition: CGPoint {
        player.position - CGPoint(x: 0, y: player.size.height/2)
    }
    var playerFootDifference: CGPoint {
        player.position - playerFootPosition
    }
    var previousPlayerMovements: [CGPoint] = []
    var nextPlayerMovements: [CGPoint] = []
    var isPlayerWalking = false
    let blocksPerSecond: Double = 3
    
    let generator = UINotificationFeedbackGenerator()
    
    // ===
    
    var lastTargetGridNode: GridNode!
    
    private var grid: Grid!
    var gridNodeSize: CGSize!
    
    override func didMove(to view: SKView) {
        player = childNode(withName: "player") as? SKSpriteNode
        let pieceSpawnPointNode = childNode(withName: "pieceSpawn")!
        enemy = childNode(withName: "enemy") as? SKSpriteNode
        cameraNode = camera!
        
        pieceSpawnPoint = pieceSpawnPointNode.position
        spawnPointCameraOffSet = pieceSpawnPoint.y - cameraNode.position.y
        playerCameraOffSet = cameraNode.position.y - player.position.y
        
        maxCameraY = cameraNode.position.y
        
        initialPlayerPosition = player.position
        initialEnemyPosition = enemy.position
        initialCameraPosition = camera?.position
        
        initialEnemySpeed = enemySpeed
        initialEnemySpeedAcceleration = enemySpeedAcceleration
        
        
        
        grid = Grid(in: self, playerHeight: player.size.height, playerPosition: player.position)
        gridNodeSize = grid.gridNodeSize
        
        spawnRandomPiece()
        spawnBase()
        spawnZeroRow()
        
        animationSetup()
        spawnCat()
        rescueCat()
        spawnPotion()
    }
    
    
    fileprivate func spawnBase() {
        let gridContainer = grid.gridContainer
        
        if let playerGridNode = gridContainer.atPoint(convert(playerFootPosition, to: gridContainer)) as? GridNode {
            let blockNode = BlockNode(blockSize: grid.gridNodeSize, category: .target, blockType: .grass)
            lastTargetGridNode = playerGridNode
            playerGridNode.addBlockNode(blockNode: blockNode)
        }
    }
    
    fileprivate func spawnZeroRow() {
        let position = playerFootPosition -  CGPoint(x: grid.gridNodeSize.width, y: grid.gridNodeSize.height)
        
        let nodes = grid.generateGridRow(y: position.y)
        
        for node in nodes {
            let blockNode = BlockNode(blockSize: grid.gridNodeSize, category: .target, blockType: .grass)
            
            node.addBlockNode(blockNode: blockNode)
        }
        
    }
    
    private var startingDragPosition: CGPoint?
    func touchDown(atPoint pos : CGPoint) {
        if let node = nodes(at: pos).first {
            if node.name == "rotatable_piece" {
                movingNode = pieceNode.container
                movingNode?.alpha = 0.7
                startingDragPosition = pos
            }
        }
    }
    
    func canPlacePiece() -> Bool {
        
        for blockNode in pieceNode.getBlockNodes() {
            if let gridNode = grid.getGridNode(for: blockNode) {
                if gridNode.containsABlockNode {
                    return false
                }
            } else {
                return false
            }
        }
        
        let startNode = pieceNode.getStartNode()
        let startGridNode = grid.getGridNode(for: startNode)
        
        if let startGridNode = startGridNode,
           startGridNode.isNeighbour(to: lastTargetGridNode) {
            return true
        }
        
        return false
    }
    
    
    
    func touchMoved(toPoint pos : CGPoint) {
        if let movingNode = movingNode {
            if movingNode == pieceNode.container {
                pieceNode.container.position = pos
                
                let canPlace = canPlacePiece()
                
                grid.highlightGrid(basedOn: pieceNode, canPlace: canPlace)
            }
            
            lastTouchPosition = pos
        }
    }
    
    func createNextMoveAction() -> SKAction? {
        guard !nextPlayerMovements.isEmpty else { return nil }
        
        let nextPosition = nextPlayerMovements.removeFirst()
        previousPlayerMovements.append(nextPosition)
        
        let moveAction = SKAction.move(to: nextPosition + playerFootDifference, duration: 1/blocksPerSecond)
        
        return moveAction
    }
    
    func runLoopMoveAction(moveAction: SKAction) {
        player.run(moveAction) { [weak self] in
            if let nextMoveAction = self?.createNextMoveAction() {
                self?.runLoopMoveAction(moveAction: nextMoveAction)
            } else {
                self?.isPlayerWalking = false
            }
        }
    }
    
    func addPositionsPlayerQueue(positions: [CGPoint]) {
        print("Current position: \(player.position)")
        print("Adding positions: \(positions)")
        
        nextPlayerMovements.append(contentsOf: positions)
        if !isPlayerWalking,
           let moveAction = createNextMoveAction() {
            isPlayerWalking = true
            runLoopMoveAction(moveAction: moveAction)
        }
    }
    
    fileprivate func placePiece() {
        let orderedBlockNodes = pieceNode.getOrderedBlockNodes()
        
        let orderedGridNodes = orderedBlockNodes.compactMap { blockNode in
            grid.getGridNode(for: blockNode)
        }
        
        let playerPositions = orderedGridNodes.map { gridNode in
            convert(gridNode.position, from: grid.gridContainer)
        }
        
        addPositionsPlayerQueue(positions: playerPositions)
        
        for blockNode in pieceNode.getBlockNodes() {
            if let gridNode = grid.getGridNode(for: blockNode) {
                if blockNode.category == .target {
                    lastTargetGridNode = gridNode
                }
                
                gridNode.addBlockNode(blockNode: blockNode)
            }
        }
        spawnRandomPiece()
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if movingNode == pieceNode.container {
            movingNode?.alpha = 1
            
            // se ta pertinho, rotate
            if let startingPosition = startingDragPosition,
               startingPosition.distance(to: pos) < 40 {
                pieceNode.rotate()
                // se nao ta pertinho, tenta colocar
            } else if canPlacePiece() {
                placePiece()
                generator.notificationOccurred(.success)
            } else if let startingDragPosition = startingDragPosition {
                pieceNode.container.position = startingDragPosition
            }
            
            startingDragPosition = nil
            grid.setHighlightOff()
            
        }
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
    
    fileprivate func spawnRandomPiece() {
        createdPieces += 1
        
        if let piece = PieceFactory.shared.buildRandomPiece() {
            let container = SKNode()
            container.position = cameraNode.position + CGPoint(x: 0, y: spawnPointCameraOffSet)
            addChild(container)
            
            pieceNode = PieceNode(piece: piece, container: container, startingZPosition: -5 + (Int(-createdPieces) * 4), blockSize: gridNodeSize)
        }
    }
    
    
    func spawnCat() {
        let newCat = SKSpriteNode(imageNamed: "cat")
        newCat.position = cameraNode.position + CGPoint.randomPoint(totalLength: 100)
        newCat.setScale(0.4)
        cat = newCat
        newCat.name = "cat"
        addChild(cat)
    }
    
    func rescueCat() {
        if player.intersects(cat) {
            catsRescued += 1
            pointsCounter += 60
            cat.removeFromParent()
            print("pegou")
            spawnCat()
        }
    }
    
    func spawnPotion() {
        let newPotion = SKSpriteNode(imageNamed: "potion")
        newPotion.position = cameraNode.position + CGPoint.randomPoint(totalLength: 100)
        newPotion.setScale(0.4)
        potion = newPotion
        newPotion.name = "potion"
        addChild(potion)
    }
    
    func pickPotion() {
        if player.intersects(potion) {
            potion.removeFromParent()
            // here i reduced the speed but idealy it will reduce the size of the enemy
            enemySpeed = -enemySpeed / 2
        }
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
        
        if nodes(at: newPosition).contains(where: { node in node.name == "base" || node.name == "cat" || node.name == "potion"}) {
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
        
        cat.removeFromParent()
        cat = nil
        spawnCat()
        
        GameCenterManager.shared.updateScore(with: pointsCounter)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let movingNode = movingNode {
            if movingNode.name == "player",
               let lastTouchPosition = lastTouchPosition {
                movePlayer(lastTouchPosition: lastTouchPosition)
            }
        }
        
        //        moveEnemy()
        checkEnemyHitPlayer()
        updateEnemySpeed()
        rescueCat()
        pickPotion()
        
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
