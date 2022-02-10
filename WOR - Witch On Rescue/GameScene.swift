//
//  GameScene.swift
//  NanoBusinessMechanics
//
//  Created by Daniella Onishi on 27/01/22.
//

import SpriteKit
import GameplayKit
import AVFoundation

// think -- camera follows cat when he dies
// thonk -- fog delay after starting

protocol GameSceneDelegate: AnyObject {

    func presenteGameOver()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var player : PlayerNode!
    private var cameraNode: SKCameraNode!
    private var enemy: SKSpriteNode!
    private var movingNode: SKNode?
    private var potion: PotionNode!
    private var pieceSpawnPoint: CGPoint!
    private var catSpawnPoint: CGPoint!
    
    // think -- delay fog after starting
    private var enemySpeed: CGFloat = 28 // Speed per second
    private var enemySpeedAcceleration: CGFloat = 0.007 // Adds to the enemy spee every tick
    private var enemySpeedAccelerationIncrease: CGFloat = 0.0005 // Adds to the enemy acceleration every tick
    private var maxEnemySpeed: CGFloat = 80
    
    private var maxCameraY: CGFloat = 0
    private var spawnPointCameraOffSet: CGFloat = 0
    private var playerCameraOffSet: CGFloat = 0
    var createdPieces: CGFloat = 2
    
    var catsRescued = SharedData.shared.catsRescued
    var pointsCounter = SharedData.shared.pointsCounter
    
    private var initialPlayerPosition: CGPoint!
    private var initialCameraPosition: CGPoint!
    private var initialEnemyPosition: CGPoint!
    var originalPlayerFootPosition: CGPoint!
    
    private var initialEnemySpeed: CGFloat!
    private var initialEnemySpeedAcceleration: CGFloat!
    
    private var pieceNode: PieceNode!
    private var gameCenterManager: GameCenterManager!
    weak var gameSceneDelegate: GameSceneDelegate?
    
    var lastTargetGridNode: GridNode!
    private var grid: Grid!
    var gridNodeSize: CGSize!
    
    var catsRescuedLabel: SKLabelNode!
    var pointsCounterLabel: SKLabelNode!
    var enemyDistanceLabel: SKLabelNode!
    
    let generator = UINotificationFeedbackGenerator()
    
    var endedGame = false
    var placedFirstPiece = false
    
    var topY: CGPoint!
    var enemyDistance: CGFloat!
    
    override func didMove(to view: SKView) {
        let playerSpawn = childNode(withName: "playerSpawn") as? SKSpriteNode
        player = PlayerNode()
        player.delegate = self
        player.position = playerSpawn!.position
        addChild(player)
        let pieceSpawnPointNode = childNode(withName: "pieceSpawn")!
        enemy = childNode(withName: "fog") as? SKSpriteNode
        cameraNode = camera!
        catsRescuedLabel = cameraNode.childNode(withName: "catsRescuedLabel") as? SKLabelNode
        pointsCounterLabel = cameraNode.childNode(withName: "pointsCounterLabel") as? SKLabelNode
        
        calculateEnemyDistance()
        enemyDistanceLabel = cameraNode.childNode(withName: "Enemy distance") as? SKLabelNode
        
        originalPlayerFootPosition = player.playerFootPosition
        
        pieceSpawnPoint = pieceSpawnPointNode.position
        spawnPointCameraOffSet = pieceSpawnPoint.y - cameraNode.position.y
        playerCameraOffSet = cameraNode.position.y - player.position.y
        
        maxCameraY = cameraNode.position.y
        
        initialPlayerPosition = player.position
        initialEnemyPosition = enemy.position
        initialCameraPosition = camera?.position
        
        initialEnemySpeed = enemySpeed
        initialEnemySpeedAcceleration = enemySpeedAcceleration
        
        grid = Grid(in: self)
        grid.generateInitialGrid(playerFootPosition: player.playerFootPosition)
        gridNodeSize = grid.gridNodeSize
        
        spawnPiece(piece: PieceFactory.shared.build(type: .line)!)
        spawnZeroRow()
        player.animationSetup()
        spawnPotion()
        spawnBase()
        
        SharedData.shared.pointsCounter = 0
        SharedData.shared.catsRescued = 0
        
        physicsWorld.contactDelegate = self
        topY = camera?.position
        
        for _ in 0...10 {
            spawnCat()
        }
        // Only do ONCE and at the end
        let newPlayerScale = (grid.gridNodeSize.height / player.size.height) * 1.2
        player.setScale(newPlayerScale)
    }
    
    fileprivate func spawnBase() {
        let gridContainer = grid.gridContainer
        
        if let playerGridNode = gridContainer.atPoint(convert(player.playerFootPosition, to: gridContainer)) as? GridNode {
            let blockNode = BlockNode(blockSize: grid.gridNodeSize, category: .target, blockType: .grass)
            lastTargetGridNode = playerGridNode
            playerGridNode.addBlockNode(blockNode: blockNode)
            
            player.position = convert(playerGridNode.position, to: self) + player.playerFootDifference / 2
        }
    }
    
    fileprivate func spawnZeroRow() {
        let position = player.playerFootPosition -  CGPoint(x: grid.gridNodeSize.width, y: grid.gridNodeSize.height)
        
        let nodes = grid.generateGridRow(y: position.y, rowIndex: 0)
        
        for node in nodes {
            let blockNode = BlockNode(blockSize: grid.gridNodeSize, category: .block, blockType: .grass)
            
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
    
    func calculateEnemyDistance() {
        enemyDistance = round(player.position.y - enemy.position.y)
    }
    
    func removeOldPieces() {
        let maxPieceCount = 5
        guard player.previousPlayerMovements.count > maxPieceCount else { return }
        
        for i in 0..<(player.previousPlayerMovements.count - maxPieceCount) {
            let position = player.previousPlayerMovements[i]
            let gridNode = grid.getGridNode(for: convert(position, to: grid.gridContainer))
            
            print("Removing piece in \(position)")
            
            gridNode?.removeBlock(animated: true, index: i)
        }
        
        player.previousPlayerMovements.removeFirst(player.previousPlayerMovements.count - maxPieceCount)
    }
    
    fileprivate func placePiece() {
        let orderedBlockNodes = pieceNode.getOrderedBlockNodes()
        
        let orderedGridNodes = orderedBlockNodes.compactMap { blockNode in
            grid.getGridNode(for: blockNode)
        }
        
        let playerPositions = orderedGridNodes.map { gridNode in
            convert(gridNode.position, from: grid.gridContainer)
        }
        
        player.addPositionsPlayerQueue(positions: playerPositions)
        
        for blockNode in pieceNode.getBlockNodes() {
            if let gridNode = grid.getGridNode(for: blockNode) {
                if blockNode.category == .target {
                    lastTargetGridNode = gridNode
                }
                
                gridNode.addBlockNode(blockNode: blockNode)
            }
        }
        placedFirstPiece = true
        spawnRandomPiece()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "player" {
            playerContact(object: contact.bodyB.node)
        } else if contact.bodyB.node?.name == "player" {
            playerContact(object: contact.bodyA.node)
        } else if contact.bodyA.node?.name == "fog" {
            enemyContact(object: contact.bodyB.node)
        } else if contact.bodyB.node?.name == "fog" {
            enemyContact(object: contact.bodyA.node)
        }
    }
    
    func playerContact(object: SKNode?) {
        if object == nil {
            return
        }
        if object!.name == "cat" {
            rescueCat(node: object!)
        } else if object!.name == "fog" {
            endGame()
        } else if object!.name == "potion" {
            pickPotion(node: object!)
        }
    }
    
    func enemyContact(object: SKNode?) {
        if object == nil {
            return
        }
        if object!.name == "cat" {
            endGame()
        } else if object!.name == "player" {
            endGame()
        }
    }
  
    func touchMoved(toPoint pos : CGPoint) {
        if let movingNode = movingNode {
            if movingNode == pieceNode.container {
                pieceNode.container.position = pos
                
                let canPlace = canPlacePiece()
                
                grid.highlightGrid(basedOn: pieceNode, canPlace: canPlace)
            }
        }
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
            } else {
                pieceNode.container.position = cameraNode.position + CGPoint(x: 0, y: spawnPointCameraOffSet)
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
        if let piece = PieceFactory.shared.buildRandomPiece() {
            spawnPiece(piece: piece)
        }
    }
    
    func spawnPiece(piece: Piece) {
        createdPieces += 1
        
        let container = SKNode()
        container.position = cameraNode.position + CGPoint(x: 0, y: spawnPointCameraOffSet)
        addChild(container)
        pieceNode = PieceNode(piece: piece, container: container, startingZPosition: 3, blockSize: gridNodeSize)
    }
    
    func spawnCat() {
        let newCat = CatNode()
        let targetCatPosition = topY + CGPoint.randomPoint(totalLength: 100)
        topY = topY + CGPoint(x: 0, y: 400)
        let catGridNode = grid.getGridNode(for: targetCatPosition)
        newCat.position = convert(catGridNode!.position, from: grid.gridContainer)
        addChild(newCat)
    }
    
    func spawnPotion() {
        let newPotion = PotionNode()
        let targetPotionPosition = cameraNode.position + CGPoint.randomPoint(totalLength: 100)
        let potionGridNode = grid.getGridNode(for: targetPotionPosition)
        newPotion.position = convert(potionGridNode!.position, from: grid.gridContainer)
        newPotion.setScale(0.6)
        addChild(newPotion)
    }
    
    func rescueCat(node: SKNode) {
            catsRescued += 1
            pointsCounter += 60
        SharedData.shared.pointsCounter = pointsCounter
        SharedData.shared.catsRescued = catsRescued
            node.removeFromParent()
            spawnCat()
            updateScore()
        SFXMusicSingleton.shared.pickCatSFX()
    }
    
    func updateScore() {
        catsRescuedLabel.text = "\(catsRescued)"
        pointsCounterLabel.text = "\(pointsCounter)"
    }
   
    func pickPotion(node: SKNode) {
            node.removeFromParent()
            enemySpeed = 20
            spawnPotion()
    }
    
    func updateCamera(playerPosition: CGPoint) {
        self.cameraNode.position.y = playerPosition.y + playerCameraOffSet
    }
    
    func moveEnemy() {
        let direction = CGPoint(x: 0, y: 1)
        let normalized = direction.normalized()
        let newPosition = enemy.position + (normalized * enemySpeed / 60)
        
        enemy.position = newPosition
        
        print("\(round(enemySpeed))")
    }
    
    func updateEnemySpeed() {
        if enemySpeed < maxEnemySpeed {
            enemySpeed += enemySpeedAcceleration
            enemySpeedAcceleration += enemySpeedAccelerationIncrease
        }
    }
    
    func checkEnemyHitPlayer() {
        if enemy.intersects(player) {
            endGame()
        }
    }
    
//    func resetGame() {
//        maxCameraY = initialCameraPosition.y
//
//        player.position = initialPlayerPosition
//        camera!.position = initialCameraPosition
//
//        print("Resetting...")
//
//        enemy.position = initialEnemyPosition
//        enemySpeed = initialEnemySpeed
//        enemySpeedAcceleration = initialEnemySpeedAcceleration
//
//        cat.removeFromParent()
//        cat = nil
//        spawnCat()
//
//        GameCenterManager.shared.updateScore(with: pointsCounter)
//
//        // Limpar grid
//        // Repositionar spawned piece
//
//        grid.gridContainer.removeFromParent()
//
//        grid = Grid(in: self)
//        grid.generateInitialGrid(playerFootPosition: originalPlayerFootPosition)
//        gridNodeSize = grid.gridNodeSize
//
//        pieceNode.container.removeFromParent()
//        pieceNode = nil
//        spawnRandomPiece()
//        spawnBase()
//        spawnZeroRow()
//    }
    
    func endGame() {
        guard !endedGame else { return }
        endedGame = true
    
        
        GameCenterManager.shared.updateScore(with: pointsCounter)
        SharedData.shared.savePoints(points: Score(points: pointsCounter))
        
        gameOverScreen()
        
        // Salva pontos no user defaults
    }
      
    func gameOverScreen() {
        gameSceneDelegate?.presenteGameOver()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if endedGame {
            return
        }
        // Called before each frame is rendered
        updateCamera(playerPosition: player.position)
        // rescueCat()
        if placedFirstPiece {
            moveEnemy()
            updateEnemySpeed()

        }
        calculateEnemyDistance()
        enemyDistanceLabel.text = enemyDistance.description
    }
}

extension GameScene: PlayerNodeDelegate {
    func moveDone() {
        removeOldPieces()
    }
}
