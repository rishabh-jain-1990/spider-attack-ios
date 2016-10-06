//
//  GameView.swift
//  SpiderAttack
//
//  Created by Rishabh Jain on 9/22/16.
//  Copyright © 2016 Bowstring Studio LLP. All rights reserved.
//

import Foundation
import SpriteKit


class GameView : SKView
{
    
    override var isPaused : Bool {
        didSet {
            if self.isPaused {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "paused"), object: nil, userInfo: nil)
            }
            else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "un-paused"), object: nil, userInfo: nil)
            }
        }
        
    }
}
