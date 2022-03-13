//
//  Grid.swift
//  WOR - Witch On Rescue
//
//  Created by Daniella Onishi on 02/02/22.
//

import Foundation
import SpriteKit

class Grid {
    
    let gridContainer = SKNode()
    
    private let gridHorizontalMargin: CGFloat = 20
    private let gridColumnCount: CGFloat = 7
    private let gridAspectRatio: CGFloat = 0.8 // graminha height / width
    private var gridRows: [Int : [GridNode]] = [:]
    private var startingPlayerFootStartPosition: CGPoint = .zero
    var lastCreatedRow: Int = 0
   
    lazy var initialGridRowCount: Int = {
        return Int(sceneSize.height / gridNodeSize.height) + 1500
    }()
    
    lazy var gridNodeSize: CGSize = {
        let nodeWidth = (sceneSize.width - gridHorizontalMargin * 2) / gridColumnCount
        let nodeHeight = nodeWidth * gridAspectRatio
        return CGSize(width: nodeWidth, height: nodeHeight)
    }()
    
    let sceneSize: CGSize
    
    init(in scene: SKScene) {
        sceneSize = scene.size
        scene.addChild(gridContainer)
    }
    
    func calculateRowOffSet(row: CGFloat) -> CGFloat {
        return row * gridNodeSize.height
        
    }
    func generateInitialGrid(playerFootPosition: CGPoint) {
        startingPlayerFootStartPosition = playerFootPosition
        for row in 0..<initialGridRowCount {
            let offset = calculateRowOffSet(row: CGFloat(row))
            _ = generateGridRow(y: playerFootPosition.y + offset, rowIndex: -(CGFloat(row + 1)))
        }
    }
    
    func generateGridRow(y: CGFloat, rowIndex: CGFloat) -> [GridNode] {
        let row = -rowIndex - 1
        let nodeSize = gridNodeSize
        var generatedNodes: [GridNode] = []
        
        func calculateOffset(j: Int) -> (CGFloat) {
            let defaultWidthOffset = -CGFloat(nodeSize.width) * ((gridColumnCount - 1) / 2) // 1.5 is a full block plus half a block
            let offsetWidthChange = CGFloat(j) * nodeSize.width
            let finalWidthOffset = defaultWidthOffset + offsetWidthChange
            
            return (finalWidthOffset)
        }
        
        for j in 0..<Int(gridColumnCount) {
            let gridNode = GridNode(size: nodeSize, position: CGPoint(x: calculateOffset(j: j), y: y), zPosition: 5, contentZPosition: rowIndex)
            gridContainer.addChild(gridNode)
            generatedNodes.append(gridNode)
        }
        gridRows[Int(row)] = generatedNodes
        
        if Int(row) > lastCreatedRow {
            lastCreatedRow  = Int(row)
        }
        
        return generatedNodes
        
    }
    
    var highlightedNodes: [GridNode] = []
    
    func highlightGrid(basedOn pieceNode: PieceNode, canPlace: Bool) {
        // pega todos os nós da pieceNode
        let blockNodes = pieceNode.getBlockNodes()
        var newHighlightedNodes: [GridNode] = []
        
        for blockNode in blockNodes {
            
            // pega o no naquela posicao na grid
            if let gridNode = getGridNode(for: blockNode) {
                // da highlight nele
                let highlightMode: HighlightMode = canPlace ? .placeable : .hovering
                gridNode.setHighlighted(highlightMode: highlightMode)
                
                newHighlightedNodes.append(gridNode)
            }
        }
        
        // para cada veio aceso que nao esta em novos acesos
        for oldHighlihtedNode in highlightedNodes where !newHighlightedNodes.contains(oldHighlihtedNode) {
            oldHighlihtedNode.setHighlightOff()
        }
        
        highlightedNodes = newHighlightedNodes
        
    }
    
    func getGridNode(for blockNode: BlockNode) -> GridNode? {
        // pega a posicao
        let blockPosition = blockNode.position
        
        // pega a posicao na grid
        if let parent = blockNode.parent {
            let gridPosition = gridContainer.convert(blockPosition, from: parent)
            return getGridNode(for: gridPosition)
        }
        
        return nil
    }
    
    func getGridNode(for position: CGPoint) -> GridNode? {
        return gridContainer.atPoint(position) as? GridNode
    }
    
    func setHighlightOff() {
        for oldHighlihtedNode in highlightedNodes {
            oldHighlihtedNode.setHighlightOff()
        }
        
    }
    
    func update(playerFootY: CGFloat) {
        //pegar a row do player
        // tirar todas as rows abaixo do player - 1000
        // adicionar n rows acima da ultima (n = total de rows tiradas)
        let row = getGridRow(y: playerFootY)
        let rowsToRemove = gridRows.keys.filter({$0 < row - 1000 && gridRows[$0] != nil } )
        rowsToRemove.forEach { row in
            gridRows[row]?.forEach({$0.removeFromParent()})
            gridRows[row] = nil
        }
        for newRow in 0..<rowsToRemove.count {
            let row = lastCreatedRow + 1
            let rowIndex = -(CGFloat(row + 1))
            let offSet = calculateRowOffSet(row: CGFloat(row))
            generateGridRow(y: startingPlayerFootStartPosition.y + offSet, rowIndex: rowIndex)
            
        }
    }
    
    func getGridRow(y: CGFloat) -> Int {
        Int(ceil((y - startingPlayerFootStartPosition.y) / gridNodeSize.height)) 
    }
}

class GridNode: SKSpriteNode {
    
    let contentZPosition: CGFloat
    var blockNode: BlockNode?
    var containsABlockNode: Bool {
        return blockNode != nil
    }
    
    internal init(size: CGSize, position: CGPoint, zPosition: CGFloat, contentZPosition: CGFloat) {
        self.contentZPosition = contentZPosition
        super.init(texture: nil, color: .clear, size: .zero)
        self.zPosition = zPosition
        self.size = size
        self.position = position
        self.color = .clear
        self.zPosition = 0
        self.name = "grid_node"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHighlighted(highlightMode: HighlightMode) {
        switch highlightMode {
        case .placeable:
            color = .green.withAlphaComponent(0.2)
        case .hovering:
            color = .purple.withAlphaComponent(0.4)
        }
    }
    
 
    
    func setHighlightOff() {
        color = .clear
    }
    
    func addBlockNode(blockNode: BlockNode) {
        if blockNode.parent != nil {
            blockNode.removeFromParent()
        }
        blockNode.name = ""
        blockNode.zPosition = contentZPosition
        blockNode.position = .zero
        self.blockNode = blockNode
        addChild(blockNode)
    }
    
    func removeBlock(animated: Bool = true, index: Int) {
        guard let blockNode = blockNode else {
            return
        }
        
        let newBlockNodePosition = convert(blockNode.position, to: scene!)
        blockNode.removeFromParent()
        blockNode.position = newBlockNodePosition
        
        if animated {
            scene?.addChild(blockNode)
            
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: Double(index) * 0.4),
                SKAction.group([
                    SKAction.fadeOut(withDuration: 2),
                    SKAction.scale(to: 0.5, duration: 2)
                ])
            ])
            
            blockNode.run(sequence) {
                blockNode.removeFromParent()
            }
        }
        self.blockNode = nil
    }
    
    func isNeighbour(to other: GridNode) -> Bool {
        if position.y == other.position.y, abs(position.x - other.position.x) == size.width {
            return true
        } else if position.x == other.position.x, abs(position.y - other.position.y) == size.height{
            return true
        }
        return false
    }
    
}

enum HighlightMode {
    case placeable
    case hovering
}
