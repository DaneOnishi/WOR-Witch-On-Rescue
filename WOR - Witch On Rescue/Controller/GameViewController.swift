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

class GameViewController: UIViewController, GADFullScreenContentDelegate {
    
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
        
        show(state: .start)
        
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
        loadRewardedAd()
    }
    
    @IBAction func startButtonOnPress(_ sender: Any) {
        show(state: .game)
    }
    
    @IBAction func rankingButtonOnPress(_ sender: Any) {
    }
    
    @IBAction func presentAd(_ sender: Any) {
        if let ad = rewardedAd {
             ad.present(fromRootViewController: self) {
               let reward = ad.adReward
               print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
               // TODO: Reward the user.
             }
           } else {
             let alert = UIAlertController(
               title: "Rewarded ad isn't available yet.",
               message: "The rewarded ad cannot be shown at this time",
               preferredStyle: .alert)
             let alertAction = UIAlertAction(
               title: "OK",
               style: .cancel,
               handler: { [weak self] action in
                   self?.show(state: .gameOver)
               })
             alert.addAction(alertAction)
             self.present(alert, animated: true, completion: nil)
           }
    }
    
    fileprivate func loadRewardedAd() {
        GADRewardedAd.load(
            withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: GADRequest()
        ) { (ad, error) in
            if let error = error {
                print("Rewarded ad failed to load with error: \(error.localizedDescription)")
                return
            }
            print("Loading Succeeded")
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }
    
    func ad(
        _ ad: GADFullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
      ) {
        print("Rewarded ad failed to present with error: \(error.localizedDescription).")
        let alert = UIAlertController(
          title: "Rewarded ad failed to present",
          message: "The reward ad could not be presented.",
          preferredStyle: .alert)
        let alertAction = UIAlertAction(
          title: "Drat",
          style: .cancel,
          handler: { [weak self] action in
              self?.show(state: .gameOver)
          })
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
      }

      deinit {
        NotificationCenter.default.removeObserver(
          self,
          name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(
          self,
          name: UIApplication.didBecomeActiveNotification, object: nil)
      }
    
    @IBAction func refuseAdButton(_ sender: Any) {
        show(state: .gameOver)
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
        
        show(state: .reward)
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
            } completion: { _ in
                
//                view.isHidden = true
            }

        }
        
        UIView.animate(withDuration: 0.15) {
            let view = self.viewsForState[state]
//            view?.isHidden = false
            view?.alpha = 1
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

enum GameState: NSInteger {
  case notStarted
  case playing
  case paused
  case ended
}
