//
//  SampleClass.swift
//  WOR - Witch On Rescue
//
//  Created by Daniella Onishi on 07/02/22.
//

import Foundation
import FirebaseAnalytics

class SampleClass{
    func triggerEvents() {
        AnalyticsManager.shared.log(event: .gameRestart)
        AnalyticsManager.shared.log(event: .levelUp(2))
        AnalyticsManager.shared.log(userProperty: .age(22))
    }
}
