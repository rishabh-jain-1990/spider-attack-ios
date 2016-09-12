//
//  GameState.swift
//  SpiderAttack
//
//  Created by Rishabh Jain on 9/12/16.
//  Copyright © 2016 Bowstring Studio LLP. All rights reserved.
//

import Foundation
struct GameState {
    static let Resumed      : UInt32 = 0
    static let Over   : UInt32 = 0b1       // 1
    static let Paused: UInt32 = 0b10      // 2
    static let NotStarted: UInt32 = 0b100      // 3
}