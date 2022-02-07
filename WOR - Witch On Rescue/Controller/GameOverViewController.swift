//
//  GameOverViewController.swift
//  WOR - Witch On Rescue
//
//  Created by APPLE DEVELOPER ACADEMY on 04/02/22.
//

import UIKit
import GameKit

class GameOverViewController: UIViewController, GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
    
    @IBOutlet weak var TryAgainButton: UIButton!
    @IBOutlet weak var ContinueButton: UIButton!
    @IBOutlet weak var RankingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func TryAgainOnClick(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let firstVC = storyboard.instantiateViewController(identifier: "GameViewController") as? GameViewController else { return }
                firstVC.modalPresentationStyle = .fullScreen
                self.present(firstVC, animated: true, completion: nil)
            }
    
    
    @IBAction func RankingOnClick(_ sender: Any) {
        let GameCenterVC = GKGameCenterViewController(leaderboardID: GameCenterManager.shared.gcDefaultLeaderBoard, playerScope: .global, timeScope: .allTime)
                    GameCenterVC.gameCenterDelegate = self
                    present(GameCenterVC, animated: true, completion: nil)
    }
}