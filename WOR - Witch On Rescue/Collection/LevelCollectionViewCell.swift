//
//  LevelCollectionViewCell.swift
//  Avanta Run
//
//  Created by Daniella Onishi on 30/01/22.
//

import Foundation
import SpriteKit
import UIKit

class LevelCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var levelInputButton: UIButton!
    
    var level: LevelData?
    
    func setup(level: LevelData) {
        self.level = level
        levelInputButton.setTitle(level.levelNumber.description, for: .normal) 
    }
}
