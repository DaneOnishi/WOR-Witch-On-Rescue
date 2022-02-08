//
//  StartViewController.swift
//  WOR - Witch On Rescue
//
//  Created by APPLE DEVELOPER ACADEMY on 04/02/22.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GameCenterManager.shared.authenticateLocalPlayer(currentVC: self)
    }
    
    @IBAction func startButtonOnPress(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let firstVC = storyboard.instantiateViewController(identifier: "GameViewController") as? GameViewController else {
                    return
                }
                firstVC.modalPresentationStyle = .fullScreen
                self.present(firstVC, animated: true, completion: nil)
            }
    }
