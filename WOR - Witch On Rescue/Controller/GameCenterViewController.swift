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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "GameViewCodcntroller") as! GameViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        GameCenterManager.shared.authenticateLocalPlayer(currentVC: self)
    }
}
