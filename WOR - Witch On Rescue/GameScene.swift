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

// rever constraints
// distance bar sumindo em devices pequenos
// animacao dos pontos
// duas peças
// ou poder arrastar de qq lugar
// pecitas em baixo dos bixin


// pedir para for for beck in becking como bota coisa sem encosta em otra coisa

protocol GameSceneDelegate: AnyObject {
    
    func playerLost(placedPieces: Int)
    func updateScore(catsRescued: Int, pointsCounter: Int)
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var player : PlayerNode!
    private var cameraNode: SKCameraNode!
    private var enemy: EnemyNode!
    private var movingNode: SKNode?
    private var potion: PotionNode!
    private var enemySpawnPoint: CGPoint!
    private var catSpawnPoint: CGPoint!
    private var magicOffNode: SKSpriteNode!
    private var tapToRotate: SKSpriteNode!
    private var piece1SpawnPoint: CGPoint!
    private var piece2SpawnPoint: CGPoint!
    private var enemyIndicator: SKSpriteNode!
    private var piece1SpawnPointFromCamera: CGPoint {
        return CGPoint(x:piece1SpawnPoint.x, y: 0) + CGPoint(x: 0, y: spawnPoint1CameraOffSet) + CGPoint(x: 0, y: cameraNode.position.y)
    }
    private var piece2SpawnPointFromCamera: CGPoint {
        return CGPoint(x:piece2SpawnPoint.x, y: 0) + CGPoint(x: 0, y: spawnPoint2CameraOffSet) + CGPoint(x: 0, y: cameraNode.position.y)

    }
  
    private var catsRescuedLabel: SKLabelNode!
    var pointsCounterLabel: SKLabelNode!
    var enemyDistanceLabel: SKLabelNode!
    var barNode: SKSpriteNode!
    
    
    
    private var maxCameraY: CGFloat = 0
    private var spawnPoint1CameraOffSet: CGFloat = 0
    private var spawnPoint2CameraOffSet: CGFloat = 0
    private var playerCameraOffSet: CGFloat = 0
    
    var catsRescued = SharedData.shared.catsRescued
    var pointsCounter = SharedData.shared.pointsCounter
    
    private var initialPlayerPosition: CGPoint!
    private var initialEnemyPosition: CGPoint!
    private var initialCameraPosition: CGPoint!
    var originalPlayerFootPosition: CGPoint!
    
    var createdPieces: CGFloat = 0
    var placedPieces: Int {
        Int(createdPieces - 1)
    }
    private var pieceNode1: PieceNode!
    private var pieceNode2: PieceNode!
    
    
    private var gameCenterManager: GameCenterManager!
    weak var gameSceneDelegate: GameSceneDelegate?
    
    var lastTargetGridNode: GridNode!
    private var grid: Grid!
    var gridNodeSize: CGSize!
    
    
    let generator = UINotificationFeedbackGenerator()
    
    var isGameEnded = false
    var isGamePaused = false
    var placedFirstPiece = false
    
    var shouldGrantRewardedAdRewards = false
    var viewedRewardedAdOnce = false
    
    var topY: CGPoint!
    var enemyDistance: CGFloat!
    
    var minBarWidth: CGFloat = 1
    var maxBarWidth: CGFloat!
    var maxEnemyDistanceIndicatorShows: CGFloat = 150
    
    var catScoreImage: SKSpriteNode!
    var magicNodeSpriteImage: SKSpriteNode!
    
    
    
    
    override func didMove(to view: SKView) {
        let playerSpawn = childNode(withName: "playerSpawn") as? SKSpriteNode
        player = PlayerNode()
        player.delegate = self
        player.position = playerSpawn!.position
        addChild(player)
        let enemySpawnPointNode = childNode(withName: "enemySpawn")!
        cameraNode = camera!
        pointsCounterLabel = cameraNode.childNode(withName: "pointsCounterLabel") as? SKLabelNode
        catsRescuedLabel = cameraNode.childNode(withName: "catsRescuedLabel") as? SKLabelNode
        
        magicOffNode = childNode(withName: "magicOff") as? SKSpriteNode
        tapToRotate = childNode(withName: "tapToRotate") as? SKSpriteNode
        enemyIndicator = childNode(withName: "//animation fog") as? SKSpriteNode
        
        barNode = childNode(withName: "//Bar Node") as? SKSpriteNode
        maxBarWidth = barNode.size.width
        
//        catScoreAnimation = childNode(withName: "cat label") as? SKSpriteNode

        
        
        
        print("Starting to create enemy...")
        
        enemy = EnemyNode()
        enemy.position = enemySpawnPointNode.position
        addChild(enemy)
        
        
        print("Enemy created and added...")
        
        calculateEnemyDistance()
        enemyDistanceLabel = cameraNode.childNode(withName: "Enemy distance") as? SKLabelNode
        
        originalPlayerFootPosition = player.playerFootPosition
        
        let piece1SpawnPointNode = cameraNode.childNode(withName: "piece1Spawn")!
        let piece2SpawnPointNode = cameraNode.childNode(withName: "piece2Spawn")!
        
        piece1SpawnPoint = piece1SpawnPointNode.position
        piece2SpawnPoint = piece2SpawnPointNode.position
        spawnPoint1CameraOffSet = piece1SpawnPoint.y - cameraNode.position.y
        spawnPoint2CameraOffSet = piece2SpawnPoint.y - cameraNode.position.y
        playerCameraOffSet = cameraNode.position.y - player.position.y
        
        tapToRotate.position = CGPoint(x: 0, y: piece1SpawnPoint.y - 300)
        tapToRotate.scale(to: CGSize(width: 320, height: 175))
        
        maxCameraY = cameraNode.position.y
        
        initialPlayerPosition = player.position
        initialEnemyPosition = enemy.position
        initialCameraPosition = camera?.position
        
        enemy.initialEnemySpeed = enemy.enemySpeed
        enemy.initialEnemySpeedAcceleration = enemy.enemySpeedAcceleration
        
        grid = Grid(in: self)
        grid.generateInitialGrid(playerFootPosition: player.playerFootPosition)
        gridNodeSize = grid.gridNodeSize
        
        spawnPiece(piece: PieceFactory.shared.build(type: .line)!, pieceNumber: 1)
        spawnPiece(piece: PieceFactory.shared.build(type: .mirrorL)!, pieceNumber: 2)
        spawnZeroRow()
        player.animationSetup()
        spawnPotion()
        spawnBase()
        setupLabelAnimation()
        
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
    
    func setBar(width: CGFloat) {
       barNode.size.width = width
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
        guard !isGamePaused, !isGameEnded else { return }
        
        if pos.x > 0 {
            movingNode = pieceNode1.container
        } else {
            movingNode = pieceNode2.container
        }
        
        movingNode?.alpha = 0.7
        startingDragPosition = pos
    }
    
    func getPieceNode(for pieceName: String) -> PieceNode? {
        guard pieceName.starts(with: "rotatable_piece") else { return nil }
        if pieceName.hasSuffix("1") {
            return pieceNode1
        } else if pieceName.hasSuffix("2") {
            return pieceNode2
        } else {
            return nil
        }
    }
    
    func getPieceNode(for container: SKNode) -> PieceNode? {
        if pieceNode1.container == container {
            return pieceNode1
        } else if pieceNode2.container == container {
            return pieceNode2
        } else {
            return nil
        }
    }
    
    func canPlacePiece(pieceNode: PieceNode) -> Bool {
        
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
        enemyDistance = max(round((player.position.y - player.size.height/2) - (enemy.position.y + enemy.size.height/2)) / 10, 0)
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
    
    fileprivate func placePiece(pieceNode: PieceNode) {
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
        
        AnalyticsManager.shared.log(event: .placedPiece(pieceNode.piece.type.rawValue, pieceNode.placeAttempts, pieceNode.didRotate))
        
        spawnRandomPiece(pieceNumber: pieceNode.pieceNumber)
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
    
    func setupLabelAnimation() {
        var fadeOut = SKAction.fadeAlpha(to: 0.1, duration: 0.5)
        var fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.5)
        
        
        tapToRotate.run(SKAction.repeatForever(SKAction.sequence([fadeOut,fadeIn])))
        
    }
    
    func setupSceneAnimation() {
        var fadeOut = SKAction.fadeAlpha(to: 0.1, duration: 0.5)
        var fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.5)
        
        enemyIndicator.run(SKAction.repeatForever(SKAction.sequence([fadeIn,fadeOut])))
    }
    
    func animateCatScore() {
        catScoreImage = childNode(withName: "cat score label") as? SKSpriteNode
        
        let moveCat = SKAction.move(to: catsRescuedLabel.position, duration: 0.5)
        let catDissapear = SKAction.fadeAlpha(to: 0, duration: 0.5)
        
        catScoreImage.run(SKAction.sequence([moveCat, catDissapear]))
    }
    
    func animateMagicNodeScore() {
        magicNodeSpriteImage = childNode(withName: "magic node") as? SKSpriteNode
        
        let moveMagicNodeImage = SKAction.move(to: pointsCounterLabel.position, duration: 0.5)
        let magicNodeDisappear = SKAction.fadeAlpha(to: 0, duration: 0.5)
        
        magicNodeSpriteImage.run(SKAction.sequence([moveMagicNodeImage, magicNodeDisappear]))
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
        if let movingNode = movingNode, let pieceNode = getPieceNode(for: movingNode) {
                pieceNode.container.position = pos
                
            let canPlace = canPlacePiece(pieceNode: pieceNode)
                
                grid.highlightGrid(basedOn: pieceNode, canPlace: canPlace)
        }
    }
    
    
    func touchUp(atPoint pos : CGPoint) {
        if let movingNode = movingNode, let pieceNode = getPieceNode(for: movingNode) {
            movingNode.alpha = 1
            
            // se ta pertinho, rotate
            if let startingPosition = startingDragPosition,
               startingPosition.distance(to: pos) < 40 {
                    pieceNode.rotate()
            
                
                // se nao ta pertinho, tenta colocar
            } else if canPlacePiece(pieceNode: pieceNode) {
                placePiece(pieceNode: pieceNode)
                generator.notificationOccurred(.success)
            } else {
                pieceNode.placeAttempts += 1
                pieceNode.container.position = getSpawnPoint(for: pieceNode)!
            }
            
            startingDragPosition = nil
            grid.setHighlightOff()
            
            if tapToRotate.parent != nil {
                tapToRotate.removeFromParent()
            }
            
        }
        movingNode = nil
    }
    
    func getSpawnPoint(for piece: PieceNode) -> CGPoint? {
        if piece.pieceNumber == 1 {
            return piece1SpawnPointFromCamera
        } else if piece.pieceNumber == 2 {
            return piece2SpawnPointFromCamera
        } else { return nil }
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
    
    fileprivate func spawnRandomPiece(pieceNumber: Int) {
        if let piece = PieceFactory.shared.buildRandomPiece() {
            spawnPiece(piece: piece, pieceNumber: pieceNumber)
        }
    }
    
    func spawnPiece(piece: Piece, pieceNumber: Int) {
        createdPieces += 1
        
        let container = SKNode()
        
        addChild(container)
        let pieceNode = PieceNode(piece: piece, pieceNumber: pieceNumber, container: container, startingZPosition: 3, blockSize: gridNodeSize)
        container.position = getSpawnPoint(for: pieceNode)!
        if pieceNumber == 1 {
            pieceNode1 = pieceNode
        } else {
            pieceNode2 = pieceNode
        }
        
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
    }
    
    func updateScore() {
        gameSceneDelegate?.updateScore(catsRescued: catsRescued, pointsCounter: pointsCounter)
        
        catsRescuedLabel.text = catsRescued.description
        pointsCounterLabel.text = pointsCounter.description
    }
    
    
    func pickPotion(node: SKNode) {
        node.removeFromParent()
        enemy.enemySpeed = 20
        spawnPotion()
    }
    
    func updateCamera(playerPosition: CGPoint) {
        self.cameraNode.position.y = playerPosition.y + playerCameraOffSet
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
        guard !isGameEnded else { return }
        isGameEnded = true
       
        
        GameCenterManager.shared.updateScore(with: pointsCounter)
        SharedData.shared.savePoints(points: Score(points: pointsCounter))
        
        gameOverScreen()
        
        // Salva pontos no user defaults
    }
    
//    func scoreCatAnimation() {
//        catScoreAnimation.alpha = 1
//        SKAction.move(to: catsRescuedLabel.position, duration: 0.5)
//        run(SKAction.fadeAlpha(to: 0, duration: 0.5))
//    }
    
    func gameOverScreen() {
        gameSceneDelegate?.playerLost(placedPieces: Int(createdPieces)-1)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameEnded || isGamePaused {
            return
        }
        // Called before each frame is rendered
        updateCamera(playerPosition: player.position)
        // rescueCat()
        if placedFirstPiece {
            enemy.moveEnemy()
            enemy.updateEnemySpeed()
            
        }
        calculateEnemyDistance()
        enemyDistanceLabel.text = Int(enemyDistance).description
        
        if placedFirstPiece {
            let maxAlpha = 1
            let maxDistance = CGFloat(30)
            
            let currentDistanceRatio = min(1, enemyDistance / maxDistance)
            enemyIndicator.alpha = 1 - currentDistanceRatio
        }
       
        
        let consideredEnemyDistance = max(enemyDistance, 0.01)
        let enemyDistancePercentage = 1 - min(1, consideredEnemyDistance / maxEnemyDistanceIndicatorShows)
        setBar(width: enemyDistancePercentage * maxBarWidth)
        
        if let movingNode = movingNode {
            if pieceNode1 != nil, pieceNode1.container != movingNode {
                pieceNode1.container.position = piece1SpawnPointFromCamera
            }
            
            if pieceNode2 != nil, pieceNode2.container != movingNode {
                pieceNode2.container.position = piece2SpawnPointFromCamera
            }
        }
    }
    
    func pauseGame() {
        scene?.isPaused = true
        isGamePaused = true
    }
    
    func unpauseGame() {
        scene?.isPaused = false
        isGamePaused = false
    }
    
    func revive() {
        enemy.position = enemy.position - CGPoint(x: 0, y: 1000)
        enemy.enemySpeed = enemy.initialEnemySpeed
        enemy.enemySpeedAcceleration = enemy.initialEnemySpeedAcceleration
        isGameEnded = false
    }
}

extension GameScene: PlayerNodeDelegate {
    func moveDone(playerFootPosition: CGPoint) {
        removeOldPieces()
        
        if let gridNode = grid.getGridNode(for: playerFootPosition),
           let blockNode = gridNode.blockNode,
           blockNode.category == .target,
           blockNode.removeMagic() {
            
            pointsCounter += 20
            updateScore()
        }
    }
}
