//
//  Points.swift
//  WOR - Witch On Rescue
//
//  Created by Daniella Onishi on 09/02/22.
//

import Foundation

class Score: Codable {
    var id: String
    var points: Int
    
    internal init(id: String = String.randomString(length:20), points: Int) {
        self.id = id
        self.points = points
    }
}

extension Score: Comparable {
    static func < (lhs: Score, rhs: Score) -> Bool {
        lhs.points < rhs.points
    }
    
    static func == (lhs: Score, rhs: Score) -> Bool {
        lhs.points == rhs.points
    }
}
