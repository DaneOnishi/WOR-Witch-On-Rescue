//
//  GameCenterViewController.swift
//  WOR - Witch On Rescue
//
//  Created by Daniella Onishi on 03/02/22.
//

import UIKit
import GameKit

class GameCenterViewController: UIViewController, GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated:true)
    }
    
    @IBAction func leaderboardOnClick(_ sender: Any) {
        let GameCenterVC = GKGameCenterViewController(leaderboardID: GameCenterManager.shared.gcDefaultLeaderBoard, playerScope: .global, timeScope: .allTime)
            GameCenterVC.gameCenterDelegate = self
            present(GameCenterVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        GameCenterManager.shared.authenticateLocalPlayer(currentVC: self)
    }
}
