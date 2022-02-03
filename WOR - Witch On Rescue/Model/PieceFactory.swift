//
//  PieceFactory.swift
//  WOR - Witch On Rescue
//
//  Created by Daniella Onishi on 02/02/22.
//

import Foundation

class PieceFactory {
    static let shared = PieceFactory()
    
    private init(){}
    
    private let templates: [PieceType: [[BlockCategory]]] = [
        .line: [
            [.empty, .target, .empty, .empty],
            [.empty, .block, .empty, .empty],
            [.empty, .block, .empty, .empty],
            [.empty, .start, .empty, .empty],
        ],
        .l: [
            [.empty, .start, .empty, .empty],
            [.empty, .block, .empty, .empty],
            [.empty, .block, .target, .empty],
            [.empty, .empty, .empty, .empty],
        ],
        .mirrorL: [
            [.empty, .empty, .start, .empty],
            [.empty, .empty, .block, .empty],
            [.empty, .target, .block, .empty],
            [.empty, .empty, .empty, .empty],
        ],
    ]
        
    func build(type: PieceType) -> Piece? {
        guard let template = templates[type] else {
            return nil
        }
        
        let piece = Piece(pieceMatrix: template, type: type)
        return piece 
    }
    
    func buildRandomPiece() -> Piece? {
        guard let randomType = PieceType.allCases.randomElement(),
              let randomPiece = build(type: randomType) else {
            return nil
        }
        
        let turns = Int.random(in: 0...3)
        var newPiece = randomPiece
        for _ in 0...turns {
            newPiece = newPiece.rotated()
        }
        
        return newPiece
    }
}
