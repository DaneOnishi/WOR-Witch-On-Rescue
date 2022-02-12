//
//  GameViewController.swift
//  NanoBusinessMechanics
//
//  Created by Daniella Onishi on 27/01/22.
//


// splashscreen transicao do final feia
// gato intersecta poca
// analytics funcionando bein
// animacoes
// rever usabilidade
// ver se vamos ter duaspeca
// ver se vamos poder clicar em qq lugar da tela
// lugares em que a peca nao se encaixa
// rever opcoes de jogabilidade

import UIKit
import SpriteKit
import GameKit
import AVFoundation
import GoogleMobileAds
import Lottie

class GameViewController: UIViewController {
    
    // Main Views
    @IBOutlet weak var splashScreen: AnimationView!
    @IBOutlet weak var startScreenView: UIView!
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var continueCardView: ContinueCardView!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var rankingButton: UIButton!
    
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var rankingButtonGameOverScreen: UIButton!
    
    // End Game Control stuff
    var shouldGrantRewardedAdRewards = false
    var viewedRewardedAdOnce = false
    var placedPieces: Int = 0
    
    // Game View stufxaf
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
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

// MARK: GameViewController: GameSceneDelegate
extension GameViewController: GameSceneDelegate {
    func playerLost(placedPieces: Int) {
        self.placedPieces = placedPieces
        if !viewedRewardedAdOnce {
            show(state: .reward)
        } else {
            triggerGameOver()
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


// MARK: StartScreen
extension GameViewController {
    
    @IBAction func rankingButtonOnPress(_ sender: Any) {
        let GameCenterVC = GKGameCenterViewController(leaderboardID: GameCenterManager.shared.gcDefaultLeaderBoard, playerScope: .global, timeScope: .allTime)
        GameCenterVC.gameCenterDelegate = self
        present(GameCenterVC, animated: true, completion: nil)
    }
    
    @IBAction func startButtonOnPress(_ sender: Any) {
        show(state: .game)
        AnalyticsManager.shared.log(event: .levelStart)
    }
    
    
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
}

// MARK: GameScreen
extension GameViewController {
    
}

// MARK: RewardScreen
extension GameViewController {
    @IBAction func refuseAdButton(_ sender: Any) {
        triggerGameOver()
    }
    
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
                    self?.triggerGameOver()
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
}

// MARK: GameOverScreen
extension GameViewController {
    @IBAction func tryAgainButtonOnPress(_ sender: Any) {
        show(state: .start)
        createGameScene()
    }
    
    @IBAction func rankingButtonGameOverScreenOnPress(_ sender: Any) {
        let GameCenterVC = GKGameCenterViewController(leaderboardID: GameCenterManager.shared.gcDefaultLeaderBoard, playerScope: .global, timeScope: .allTime)
        GameCenterVC.gameCenterDelegate = self
        present(GameCenterVC, animated: true, completion: nil)
    }
}

// MARK: Navigation
extension GameViewController {
    func show(state: GameViewControllerViewState) {
        
        AnalyticsManager.shared.log(event: .screenView(state.rawValue, "GameViewController"))
        
        let allNonHiddenViews = viewsForState.values.filter { view in
            view.alpha != 0 && view  != self.view
        }
        
        allNonHiddenViews.forEach { view in
            UIView.animate(withDuration: 0.15) {
                view.alpha = 0
            } completion: { _ in }
        }
        
        UIView.animate(withDuration: 0.15) {
            let view = self.viewsForState[state]
            view?.alpha = 1
        }
    }
    
    
    func triggerGameOver() {
        // Fazer evento do analytics
        AnalyticsManager.shared.log(event: .levelEnd(SharedData.shared.pointsCounter, viewedRewardedAdOnce, placedPieces))
        
        // Resetar variaveis
        viewedRewardedAdOnce = false
        placedPieces = 0
        
        // Apresentar tela
        show(state: .gameOver)
    }
    
    func triggerBackToStart() {
        
    }
}

extension GameViewController: GADFullScreenContentDelegate {
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
                self?.triggerGameOver()
            })
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension GameViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

enum GameViewControllerViewState: String {
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
