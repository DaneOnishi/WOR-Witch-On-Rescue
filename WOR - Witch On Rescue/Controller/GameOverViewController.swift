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
    @IBOutlet weak var catsRescuedLabel: UILabel!
    @IBOutlet weak var ponctuationLabel: UILabel!
    @IBOutlet weak var recordLabel: UILabel!
    
    let pointsList = SharedData.shared.fetchPoints()
    var record: Score? {
        pointsList.max()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        catsRescuedLabel.text = "\(SharedData.shared.catsRescued.description)"
        ponctuationLabel.text = "\(SharedData.shared.pointsCounter.description)"
        recordLabel.text = record?.points.description ?? ""
    }

    func reloadPoints() {
        SharedData.shared.fetchPoints()
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
