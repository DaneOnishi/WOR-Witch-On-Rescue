//
//  Piece.swift
//  NanoBusinessMechanics
//
//  Created by Daniella Onishi on 27/01/22.
//

import Foundation
import SpriteKit
import UIKit

class Piece {
    let pieceMatrix: [[BlockCategory]]
    let type: PieceType
    
    init(pieceMatrix: [[BlockCategory]], type: PieceType) {
        self.pieceMatrix = pieceMatrix
        self.type = type
    }
    
    func rotated() -> Piece {
        var matrix = pieceMatrix
        let n = pieceMatrix.count
        
        for layer in 0..<n/2 {
            let first = layer
            let last = n - 1 - layer
            
            for i in first..<last {
                let offset = i - first
                let top = matrix[first][i]
                
                // top is now left
                matrix[first][i] = matrix[last - offset][first]
                // left is now bottom
                matrix[last - offset][first] = matrix[last][last - offset]
                // bottom is now right
                matrix[last][last - offset] = matrix[i][last]
                // right is now top
                matrix[i][last] = top
            }
        }
        return Piece(pieceMatrix: matrix, type: type)
    }
}


enum BlockCategory {
    case empty
    case block
    case target
    case start
    
//    var blockImage: String {
//        switch self {
//        case .empty:
//            return "block"
//        case .block:
//            return "block"
//        case .target:
//            return "end"
//        case .start:
//            return "start"
//        }
//    }
}

enum PieceType: CaseIterable {
    case line
    case l
    case mirrorL
}
