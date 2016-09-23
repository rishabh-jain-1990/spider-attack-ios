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
    
    override var paused : Bool {
        didSet {
            if self.paused {
                NSNotificationCenter.defaultCenter().postNotificationName("paused", object: nil, userInfo: nil)
            }
            else {
                NSNotificationCenter.defaultCenter().postNotificationName("un-paused", object: nil, userInfo: nil)
            }
        }
        
    }
}