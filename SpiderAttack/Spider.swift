//
//  Spider.swift
//  SpiderAttack
//
//  Created by Rishabh Jain on 9/1/16.
//  Copyright © 2016 Bowstring Studio LLP. All rights reserved.
//

import Foundation
import SpriteKit
import Dispatch

class Spider : SKSpriteNode
{
    
    let screenHeight :CGFloat
    let line :SKSpriteNode
    private static var spiderImageArray = [SKTexture]()
    var currentImageIndex = 0;
    var countdown = 0
    
    init(screenHeight: CGFloat, line: SKSpriteNode)
    {
        self.screenHeight = screenHeight
        self.line = line
        
        let texture = SKTexture(imageNamed: "spider_00000")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        if Spider.spiderImageArray.isEmpty
        {
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00000"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00001"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00002"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00003"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00004"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00005"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00006"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00007"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00008"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00009"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00010"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00011"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00012"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00013"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00014"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00015"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00016"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00017"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00018"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00019"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00020"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00021"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00022"))
            Spider.spiderImageArray.append(SKTexture(imageNamed: "spider_00023"))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startTimer(countdown: Int)
    {
        self.countdown = countdown
        if countdown == 0
        {
            downAction()
        }else{
            performSelector(#selector(downAction), withObject: nil, afterDelay: Double(countdown))
            performSelector(#selector(changeImage), withObject: nil, afterDelay: Double(1/FRAMES_PER_SECOND))
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
        if(paused == true)
        {
            return
        }
        
        hidden = false
        let duration = NSTimeInterval(position.y / ((size.width / SPIDER_SPEED_DIVIDER) * FRAMES_PER_SECOND))
        let actionRev = SKAction.moveTo(CGPoint(x: position.x, y: size.height / 2), duration: duration);
        SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(changeImage), SKAction.waitForDuration(1)]))
        runAction(SKAction.sequence([actionRev, SKAction.runBlock(upAction)]))
        
        let lineAction = SKAction.resizeToHeight(screenHeight - size.height / 2, duration: duration)
        line.runAction(lineAction)
    }
    
    func changeImage()
    {
        if paused == true
        {
            return
        }
        //        switch movementDrection
        //        {
        //        case MovementDirection.Up, MovementDirection.Down:
        texture = getNextImage()
        performSelector(#selector(changeImage), withObject: nil, afterDelay: Double(1/FRAMES_PER_SECOND))
        //        }
    }
    
    func getNextImage() -> SKTexture
    {
        currentImageIndex += 1
        currentImageIndex = currentImageIndex > 23 ? 0 : currentImageIndex
        
        return Spider.spiderImageArray[currentImageIndex]
    }
    
    func getPreviousImage() -> SKTexture
    {
        currentImageIndex -= 1
        currentImageIndex = currentImageIndex < 0 ? 23 : currentImageIndex
        
        return Spider.spiderImageArray[currentImageIndex]
    }
    
    func pause() {
        paused = true
        line.paused = true
    }
    
    func unpause() {
        paused = false
        line.paused = false
        
        if hidden == true
        {
            if countdown > 4
            {
                performSelector(#selector(downAction), withObject: nil, afterDelay: Double(countdown - 2))
            }
            else if countdown > 1
            {
                performSelector(#selector(downAction), withObject: nil, afterDelay: Double(countdown - 1))
            }else
            {
                performSelector(#selector(downAction), withObject: nil, afterDelay: Double(countdown))
            }
        }
        
        changeImage()
    }
}