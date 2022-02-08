//
//  SharedData.swift
//  WOR - Witch On Rescue
//
//  Created by Daniella Onishi on 08/02/22.
//

import Foundation
import UIKit
import SpriteKit

class SharedData {
    static let shared = SharedData()
    private init () {}
    
    var catsRescued: Int = 0
    var pointsCounter: Int = 0
}
