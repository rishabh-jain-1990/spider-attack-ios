//
//  Spider.swift
//  SpiderAttack
//
//  Created by Rishabh Jain on 9/1/16.
//  Copyright © 2016 Bowstring Studio LLP. All rights reserved.
//

import Foundation
import SpriteKit

class Spider : SKSpriteNode
{
    let screenHeight :CGFloat
    let line :SKSpriteNode
    var countdown = 0
    var timer :NSTimer!
    
    init(screenHeight: CGFloat, line: SKSpriteNode)
    {
        self.screenHeight = screenHeight
        self.line = line
        
        let texture = SKTexture(imageNamed: "Spider")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startTimer(countdown: Int)
    {
        self.countdown = countdown
        if countdown == 0
        {
            print("Countdown skipped")
            downAction()
        }else{
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector: Selector(start()), userInfo: nil, repeats: false)
        }
    }
    
    func start()
    {
        countdown -= 1
        if countdown <= 0
        {
            print("Countdown ended")
            if timer != nil
            {
             timer.invalidate()
            }
            
            print("timer invalidated")
            downAction()
        }
    }
    
    func upAction() {
        let revY = screenHeight - CGFloat(arc4random_uniform(UInt32(screenHeight / 2 - size.height))) - size.height / 2;
        let duration = NSTimeInterval(revY / ((size.width / SPIDER_SPEED_DIVIDER) * FRAMES_PER_SECOND))
        let actionRev = SKAction.moveTo(CGPoint(x: position.x, y: revY), duration: duration);
        runAction(SKAction.sequence([actionRev, SKAction.runBlock(downAction)]))
        
        let lineAction = SKAction.resizeToHeight(screenHeight - revY, duration: duration)
        line.runAction(lineAction)
        //        player.position.x = player.position.x - (spiderWidth / BEE_SPEED_DIVIDER)
    }
    
    func downAction() {
        let duration = NSTimeInterval(position.y / ((size.width / SPIDER_SPEED_DIVIDER) * FRAMES_PER_SECOND))
        let actionRev = SKAction.moveTo(CGPoint(x: position.x, y: size.height / 2), duration: duration);
        runAction(SKAction.sequence([actionRev, SKAction.runBlock(upAction)]))
        
        let lineAction = SKAction.resizeToHeight(screenHeight - size.height / 2, duration: duration)
        line.runAction(lineAction)
        print("down action")
    }
}