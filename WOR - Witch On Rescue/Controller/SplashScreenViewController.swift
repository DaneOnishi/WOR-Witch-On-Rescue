//
//  SplashScreenViewController.swift
//  WOR - Witch On Rescue
//
//  Created by Larissa Paschoalin on 11/02/22.
//

import Foundation
import UIKit
import Lottie


final class SplashScreenViewController: UIViewController {
    
    @IBOutlet weak var splashScreen: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splashScreen?.alpha = 1
        
        setupAnimation()
    }
    
    private func setupAnimation() {
        splashScreen?.animation = Animation.named("splashScreen")
        splashScreen?.center = view.center
        splashScreen?.contentMode = .scaleAspectFill
        splashScreen?.loopMode = .playOnce
        splashScreen?.play(completion: { _ in

            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
                self.splashScreen.alpha = 0
            }

        })
    }

    
}
