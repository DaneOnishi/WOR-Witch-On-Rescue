//
//  LevelViewController.swift
//  Avanta Run
//
//  Created by Daniella Onishi on 30/01/22.
//

import SpriteKit
import UIKit

class LevelViewController: UIViewController {
   
    lazy var configurations = Configurations.shared
    @IBOutlet weak var youJourneyLabel: UILabel!
    @IBOutlet weak var levelCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        levelCollectionView.delegate = self
        levelCollectionView.dataSource = self
    }
}

extension LevelViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        configurations.levelIndexes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! LevelCollectionViewCell
        
//        let gossip = gossips[indexPath.item]
//        cell.updateUI(gossip: gossip)
        if let level = configurations.levelPredefinitions[indexPath.item + 1] {
            cell.setup(level: level)
        }
        
        
        return cell
        
        // codigo pra preparar a celular do level
       
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}


extension LevelViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let level = configurations.levelPredefinitions[indexPath.item + 1]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "GameViewController") as! GameViewController
        vc.level = level
        self.present(vc, animated: true, completion: nil)
    }
}



