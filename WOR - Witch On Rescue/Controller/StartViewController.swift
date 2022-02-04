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
        

        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


