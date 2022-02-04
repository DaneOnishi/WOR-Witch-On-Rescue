//
//  PieceNode.swift
//  WOR - Witch On Rescue
//
//  Created by Daniella Onishi on 02/02/22.
//

import Foundation
import SpriteKit

class PieceNode {
    internal init(piece: Piece, container: SKNode, startingZPosition: Int, blockSize: CGSize) {
        self.piece = piece
        self.container = container
        self.startingZPosition = startingZPosition
        self.blockSize = blockSize
        
        render()
    }
    
    var piece: Piece
    let container: SKNode // Stores all the smaller nodes
    let startingZPosition: Int // Minimum zIndex this piece uses
    
    let matrixSize = 4 // Static, might need to be changed if pieces change size
    let blockSize: CGSize // The width and height of an individual block
    
    func render() { // Builds SKSpriteNodes from the `piece`
        
        func calculateOffset(i: Int, j: Int) -> (CGFloat, CGFloat) {
            let defaultHeightOffset = CGFloat(blockSize.height) * 1.5 // 1.5 is a full block plus half a block
            let offsetHeightChange = CGFloat(i) * -blockSize.height
            let finalHeightOffset = defaultHeightOffset + offsetHeightChange
            
            let defaultWidthOffset = -CGFloat(blockSize.width) * 1.5 // 1.5 is a full block plus half a block
            let offsetWidthChange = CGFloat(j) * blockSize.width
            let finalWidthOffset = defaultWidthOffset + offsetWidthChange
            
            return (finalWidthOffset, finalHeightOffset)
        }
        
        print("[render] Generating piece: \(piece)")
        
        for (i, blockRow) in piece.pieceMatrix.enumerated() { // Checking each row of the piece (which is a matrix)
            for (j, block)  in blockRow.enumerated() {
                switch block {
                case .empty: continue
                case .start, .block, .target:
                    
                    print("[render] Generating for i: \(i), j: \(j)")
                    
                    let node = createBlockNode(category: block, blockType: .grass)
                    
                    let offset = calculateOffset(i: i, j: j)
                    
                    print("[render] offset: \(offset)")
                    
                    node.position = CGPoint(x: offset.0, y: offset.1)
                    
                    container.addChild(node)
                    
                    node.zPosition = CGFloat(startingZPosition - ((matrixSize - 1) - i)) // We basically need to assign the smallest zposition to the most close to the bottom rows
                }
            }
        }
    }
    
    func rotate() { // Rotates the piece node (and the underlying piece)
        print("[rotate] Removing all children")
        container.removeAllChildren()
        
        print("[rotate] Rotating piece...")
        piece = piece.rotated()
        
        print("[rotate] Rotated piece!")
        
        print("[rotate] Rerendering...")
        render()
    }
    
    private func createBlockNode(category: BlockCategory, blockType: BlockType) -> BlockNode {
        let node = BlockNode(blockSize: blockSize, category: category, blockType: blockType)
        node.name = "rotatable_piece"
        return node
    }
    
    func getBlockNodes() -> [BlockNode] {
        container.children .compactMap { node in
            node as? BlockNode
        }
    }
    
    func getOrderedBlockNodes() -> [BlockNode] {
        let blockNodes = getBlockNodes()
        guard blockNodes.count > 1 else {
            return [blockNodes.first!]
        }
        
        var orderedBlockNodes: [BlockNode] = []
        
        let startBlockNode = getStartNode()
        
        orderedBlockNodes.append(startBlockNode)
        
        
        
        func getFirstNeighbourNotOrdered(blockNode: BlockNode) -> BlockNode {
            let center = blockNode.position
            
            let possibleRightBlockPosition = center + CGPoint(x: blockSize.width, y: 0)
            if let rightBlock = container.nodes(at: possibleRightBlockPosition)
                .filter({ $0.position.y == blockNode.position.y && $0 != blockNode })
                .min(by: { current, other in
                    current.position.distance(to: blockNode.position) < other.position.distance(to: blockNode.position)
                }) as? BlockNode,
               !orderedBlockNodes.contains(rightBlock) {
                return rightBlock
            }
            
            let possibleLeftBlockPosition = center + CGPoint(x: -blockSize.width, y: 0)
            if let leftBlock = container.nodes(at: possibleLeftBlockPosition)
                .filter({ $0.position.y == blockNode.position.y && $0 != blockNode })
                .min(by: { current, other in
                    current.position.distance(to: blockNode.position) < other.position.distance(to: blockNode.position)
                }) as? BlockNode,
               !orderedBlockNodes.contains(leftBlock) {
                return leftBlock
            }
            
            let possibleFrontBlockPosition = center + CGPoint(x: 0, y: blockSize.height)
            if let frontBlock = container.nodes(at: possibleFrontBlockPosition)
                .filter({ $0.position.x == blockNode.position.x && $0 != blockNode })
                .min(by: { current, other in
                    current.position.distance(to: blockNode.position) < other.position.distance(to: blockNode.position)
                }) as? BlockNode,
               !orderedBlockNodes.contains(frontBlock) {
                return frontBlock
            }
            
            let possibleBackBlockPosition = center + CGPoint(x: 0, y: -blockSize.height)
            return container.nodes(at: possibleBackBlockPosition)
                .filter({ $0.position.x == blockNode.position.x && $0 != blockNode })
                .min(by: { current, other in
                    current.position.distance(to: blockNode.position) < other.position.distance(to: blockNode.position)
                })  as! BlockNode
        }
        
        while orderedBlockNodes.count < blockNodes.count {
            let lastFoundBlockNode = orderedBlockNodes.last!
            let nextBlockNode = getFirstNeighbourNotOrdered(blockNode: lastFoundBlockNode)
            orderedBlockNodes.append(nextBlockNode)
        }
        
        return orderedBlockNodes
    }
    
    func getStartNode() -> BlockNode {
        getBlockNodes()
            .first { node in
                node.category == .start
            }!
    }
    
    func getTargetNode() -> BlockNode {
        getBlockNodes()
            .first { node in
                node.category == .target
            }!
    }
}

class BlockNode: SKSpriteNode {
    
    let category: BlockCategory
    let blockType: BlockType
    
    internal init(blockSize: CGSize, category: BlockCategory, blockType: BlockType) {
        self.category = category
        self.blockType = blockType
        
        let blockTexture = blockType.randomBlockTexture(for: category)
        
        let nodeHeight = blockSize.height
        let blockHeightProportion = blockTexture.heightPercentage
        
        let actualHeight = nodeHeight / blockHeightProportion
        
        let nodeWidth = blockSize.width
        let blockWidthProportion = blockTexture.widthPercentage
        
        let actualWidth = nodeWidth / blockWidthProportion
        
        let texture = SKTexture(imageNamed: blockTexture.rawValue)
        super.init(texture: texture, color: .clear, size: CGSize(width: actualWidth, height: actualHeight))
        self.size = size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


enum BlockType {
    case grass
    
    var blockTiles: [BlockTexture] {
        switch self {
        case .grass:
            return [.block]
        }
    }
    var startTiles: [BlockTexture] {
        switch self {
        case .grass:
            return [.start]
        }
    }
    var targetTiles: [BlockTexture] {
        switch self {
        case .grass:
            return [.target]
        }
    }
    
    func randomBlockTexture(for category: BlockCategory) -> BlockTexture {
        switch category {
        case .empty:
            return .block
        case .block:
            return blockTiles.randomElement()!
        case .target:
            return targetTiles.randomElement()!
        case .start:
            return startTiles.randomElement()!
        }
    }
}

enum BlockTexture: String {
    case block = "block"
    case start = "start"
    case target = "end"
    
    var blockHeight: CGFloat {
        switch self {
        case .block:
            return 43
        case .start:
            return 43
        case .target:
            return 43
        }
    }
    
    var bottomBlockHeight: CGFloat {
        switch self {
        case .block, .target, .start:
            return 23
        }
    }
    
    var blockWidth: CGFloat {
        switch self {
        case .block, .target, .start:
            return 86.2
        }
    }
    
    var blockBorder: CGFloat {
        switch self {
        case .block, .target, .start:
            return 2.8
        }
    }
    
    var totalWidth: CGFloat {
        blockWidth + (2 * blockBorder)
    }
    
    var totalHeight: CGFloat {
        blockHeight + (2 * bottomBlockHeight)
    }
    
    var heightPercentage: CGFloat {
        blockHeight / totalHeight
    }
    
    var widthPercentage: CGFloat {
        blockWidth / totalWidth
    }
}


