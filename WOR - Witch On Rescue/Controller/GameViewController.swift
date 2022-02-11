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
    
    // Main Views
    @IBOutlet weak var splashScreenView: UIView!
    @IBOutlet weak var startScreenView: UIView!
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var continueCardView: ContinueCardView!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var rankingButton: UIButton!
    
    // Splash Screen View Stuff
    
    // Game View stuff
    var gameScene: GameScene?
    var rewardedAd: GADRewardedAd?
    var level: LevelData?
    
    lazy var viewsForState: [GameViewControllerViewState: UIView] = [
        .splash: splashScreenView,
        .start: startScreenView,
        .gameOver: gameOverView,
        .reward: continueCardView,
        .game: self.view
    ]
    
    @IBOutlet weak var catsCounter: UILabel!
    @IBOutlet weak var pointsCounterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        show(state: .splash)
        
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
    
    @IBAction func startButtonOnPress(_ sender: Any) {
        show(state: .game)
    }
    
    @IBAction func rankingButtonOnPress(_ sender: Any) {
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

// Navigation
extension GameViewController {
    func show(state: GameViewControllerViewState) {
        let allNonHiddenViews = viewsForState.values.filter { view in
            view.alpha != 0 && view  != self.view
        }
        
        allNonHiddenViews.forEach { view in
            UIView.animate(withDuration: 0.15) {
                view.alpha = 0
            }
        }
        
        UIView.animate(withDuration: 0.15) {
            self.viewsForState[state]?.alpha = 1
        }
    }
}

enum GameViewControllerViewState {
    case splash
    case start
    case game
    case reward
    case gameOver
}
