//
//  GameViewController.swift
//  NanoBusinessMechanics
//
//  Created by Daniella Onishi on 27/01/22.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import GoogleMobileAds

class GameViewController: UIViewController {
    
    enum GameState: NSInteger {
       case notStarted
       case playing
       case paused
       case ended
     }
    
    var gameScene: GameScene?
    var rewardedAd: GADRewardedAd?
    var level: LevelData?
    @IBOutlet weak var catsCounter: UILabel!
    @IBOutlet weak var pointsCounterLabel: UILabel!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SFXMusicSingleton.shared.playMainMusic()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                scene.gameSceneDelegate = self
                
                // Present the scene
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
  

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: GameSceneDelegate {
    func presenteGameOver() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let firstVC = storyboard.instantiateViewController(identifier: "GameOverViewController") as? GameOverViewController else {
            return
        }
        firstVC.modalPresentationStyle = .fullScreen
        self.present(firstVC, animated: true, completion: nil)
    }
}
