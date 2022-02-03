//
//  GameCenterManager.swift
//  WOR - Witch On Rescue
//
//  Created by Daniella Onishi on 02/02/22.
//

import GameKit

class GameCenterManager {
    static let shared = GameCenterManager()
    private init() {}
    
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = "grp.WOR"
    
    func authenticateLocalPlayer(currentVC: UIViewController) {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local

        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if ((ViewController) != nil) {
                // Show game center login if player is not logged in
                currentVC.present(ViewController!, animated: true, completion: nil)
            }
            else if (localPlayer.isAuthenticated) {
                
                // Player is already authenticated and logged in
                self.gcEnabled = true

                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil {
                        print(error!)
                    }
                    else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifer!
                    }
                 })
            }
            else {
                // Game center is not enabled on the user's device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error!)
            }
        }
    }
    
    func updateScore(with value: Int) {
          if (self.gcEnabled)
          {
              GKLeaderboard.submitScore(value, context:0, player: GKLocalPlayer.local, leaderboardIDs: [self.gcDefaultLeaderBoard], completionHandler: {error in})
          }
      }
    
}

