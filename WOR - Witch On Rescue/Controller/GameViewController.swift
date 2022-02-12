//
//  GameViewController.swift
//  NanoBusinessMechanics
//
//  Created by Daniella Onishi on 27/01/22.
//


// splashscreen transicao do final feia
// ranking button -> fazer redirecionamento para a leaderboard
// ranking button -> o mesmo c o da gameover
// tela de pause OU fodase so pausa sozinho
// logica de pause
// arrumar o contador de distância
// gato intersecta pocao
// depois de ver ad, voltar o jogo para onde estava jogado

import UIKit
import SpriteKit
import GameKit
import AVFoundation
import GoogleMobileAds
import Lottie

class GameViewController: UIViewController, GADFullScreenContentDelegate, GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
    
    
    enum GameState: NSInteger {
       case notStarted
       case playing
       case paused
       case ended
     }
    
    // Main Views
    @IBOutlet weak var splashScreen: AnimationView!
    @IBOutlet weak var startScreenView: UIView!
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var continueCardView: ContinueCardView!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var rankingButton: UIButton!
    
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var rankingButtonGameOverScreen: UIButton!
    
    // Game View stuff
    var gameScene: GameScene?
    var rewardedAd: GADRewardedAd?
    var level: LevelData?
    
    lazy var viewsForState: [GameViewControllerViewState: UIView] = [
        .splash: splashScreen,
        .start: startScreenView,
        .gameOver: gameOverView,
        .reward: continueCardView,
        .game: self.view
    ]
    
    @IBOutlet weak var catsCounter: UILabel!
    @IBOutlet weak var pointsCounterLabel: UILabel!
    
    fileprivate func createGameScene() {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                scene.gameSceneDelegate = self
                
                self.gameScene = scene
                
                // Present the scene
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        show(state: .splash)
        setupSplashAnimation()
        
        SFXMusicSingleton.shared.playMainMusic()
        
        createGameScene()
        loadRewardedAd()
        
        // Pause game when application is backgrounded.
           NotificationCenter.default.addObserver(
             self,
             selector: #selector(GameViewController.applicationDidEnterBackground(_:)),
             name: UIApplication.didEnterBackgroundNotification, object: nil)

           // Resume game when application is returned to foreground.
           NotificationCenter.default.addObserver(
             self,
             selector: #selector(GameViewController.applicationDidBecomeActive(_:)),
             name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
      // Pause the game if it is currently playing.
        gameScene?.pauseGame()
    }

    @objc func applicationDidBecomeActive(_ notification: Notification) {
      // Resume the game if it is currently paused.
        gameScene?.unpauseGame()
    }
    
    
    @IBAction func rankingButtonOnPress(_ sender: Any) {
        let GameCenterVC = GKGameCenterViewController(leaderboardID: GameCenterManager.shared.gcDefaultLeaderBoard, playerScope: .global, timeScope: .allTime)
                    GameCenterVC.gameCenterDelegate = self
                    present(GameCenterVC, animated: true, completion: nil)
    }
    
    @IBAction func startButtonOnPress(_ sender: Any) {
        show(state: .game)
    }
    
    var shouldGrantRewardedAdRewards = false
    var viewedRewardedAdOnce = false
    @IBAction func presentAd(_ sender: Any) {
        viewedRewardedAdOnce = true
        
        if let ad = rewardedAd {
             ad.present(fromRootViewController: self) {
               let reward = ad.adReward
               print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
               // TODO: Reward the user.
                 self.shouldGrantRewardedAdRewards = true
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
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if shouldGrantRewardedAdRewards {
            self.loadRewardedAd()
            gameScene?.revive()
            show(state: .game)
            shouldGrantRewardedAdRewards = false
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
    
    @IBAction func tryAgainButtonOnPress(_ sender: Any) {
        show(state: .start)
        createGameScene()
    }
    
    @IBAction func refuseAdButton(_ sender: Any) {
        show(state: .gameOver)
    }
    
    @IBAction func rankingButtonGameOverScreenOnPress(_ sender: Any) {
        let GameCenterVC = GKGameCenterViewController(leaderboardID: GameCenterManager.shared.gcDefaultLeaderBoard, playerScope: .global, timeScope: .allTime)
                    GameCenterVC.gameCenterDelegate = self
                    present(GameCenterVC, animated: true, completion: nil)
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
        if !viewedRewardedAdOnce {
            show(state: .reward)
        } else {
            show(state: .gameOver)
            viewedRewardedAdOnce = false
        }
    }
}

// MARK: SplashScreen
extension GameViewController {
    private func setupSplashAnimation() {
        splashScreen?.animation = Animation.named("splashScreen")
        splashScreen?.center = view.center
        splashScreen?.contentMode = .scaleAspectFill
        splashScreen?.loopMode = .playOnce
        splashScreen?.play(completion: { _ in

            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
                self.show(state: .start)
            }

        })
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
