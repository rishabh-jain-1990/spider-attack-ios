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
    private static var spiderTextureArray = [SKTexture]()
    private static var spiderImageArray = [UIImage]()
    var currentImageIndex = 0;
    var countdown = 0
    let minSpeed : CGFloat
    let maxSpeed : CGFloat
    
    var curSpeed : CGFloat
    
    init(width: CGFloat, screenHeight: CGFloat, line: SKSpriteNode)
    {
        self.screenHeight = screenHeight
        self.line = line
        
        minSpeed = (width / SPIDER_SPEED_DIVIDER) * FRAMES_PER_SECOND
        maxSpeed = 2 * minSpeed
        curSpeed = minSpeed
        
        let texture = SKTexture(imageNamed: "spider_00000")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        let aspectRatio = size.width / size.height
        size = CGSize(width: width, height: width / aspectRatio)
        
        if Spider.spiderTextureArray.isEmpty
        {
            Spider.spiderImageArray.append(UIImage(named: "spider_00000")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00001")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00002")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00003")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00004")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00005")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00006")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00007")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00008")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00009")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00010")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00011")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00012")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00013")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00014")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00015")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00016")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00017")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00018")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00019")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00020")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00021")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00022")!)
            Spider.spiderImageArray.append(UIImage(named: "spider_00023")!)
            
            for image in Spider.spiderImageArray
            {
                Spider.spiderTextureArray.append(SKTexture(image: image))
            }
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
            perform(#selector(downAction), with: nil, afterDelay: Double(countdown))
        }
        
        perform(#selector(changeImage), with: nil, afterDelay: Double(1/FRAMES_PER_SECOND))
    }
    
    func upAction() {
        let revY = screenHeight - CGFloat(arc4random_uniform(UInt32(screenHeight / 2 - size.height))) - size.height / 2;
        let duration = TimeInterval(revY / curSpeed)
        let actionRev = SKAction.move(to: CGPoint(x: position.x, y: revY), duration: duration);
        run(SKAction.sequence([actionRev, SKAction.run(downAction)]))
        
        let lineAction = SKAction.resize(toHeight: screenHeight - revY, duration: duration)
        line.run(lineAction)
        //        player.position.x = player.position.x - (spiderWidth / BEE_SPEED_DIVIDER)
    }
    
    func downAction() {
        if(isPaused == true)
        {
            return
        }
        
        isHidden = false
        let duration = TimeInterval(position.y / curSpeed)
        let actionRev = SKAction.move(to: CGPoint(x: position.x, y: size.height / 2), duration: duration);
        SKAction.repeatForever(SKAction.sequence([SKAction.run(changeImage), SKAction.wait(forDuration: 1)]))
        run(SKAction.sequence([actionRev, SKAction.run(upAction)]))
        
        let lineAction = SKAction.resize(toHeight: screenHeight - size.height / 2, duration: duration)
        line.run(lineAction)
    }
    
    func changeImage()
    {
        if isPaused == true
        {
            return
        }
        //        switch movementDrection
        //        {
        //        case MovementDirection.Up, MovementDirection.Down:
        texture = getNextImage()
        perform(#selector(changeImage), with: nil, afterDelay: Double(1/FRAMES_PER_SECOND))
        //        }
    }
    
    func getNextImage() -> SKTexture
    {
        currentImageIndex += 1
        currentImageIndex = currentImageIndex > 23 ? 0 : currentImageIndex
        
        return Spider.spiderTextureArray[currentImageIndex]
    }
    
    func getPreviousImage() -> SKTexture
    {
        currentImageIndex -= 1
        currentImageIndex = currentImageIndex < 0 ? 23 : currentImageIndex
        
        return Spider.spiderTextureArray[currentImageIndex]
    }
    
    func getCurrentImage() -> UIImage
    {
        return Spider.spiderImageArray[currentImageIndex]
    }
    
    func pause() {
        isPaused = true
        line.isPaused = true
    }
    
    func unpause() {
        isPaused = false
        line.isPaused = false
        
        if isHidden == true
        {
            if countdown > 4
            {
                perform(#selector(downAction), with: nil, afterDelay: Double(countdown - 2))
            }
            else if countdown > 1
            {
                perform(#selector(downAction), with: nil, afterDelay: Double(countdown - 1))
            }else
            {
                perform(#selector(downAction), with: nil, afterDelay: Double(countdown))
            }
        }
        
        changeImage()
    }
    
    func speedUp()
    {
        curSpeed += minSpeed / (SPIDER_SPEED_STEP_DIVIDER * SPIDER_SPEED_STEP_DURATION);
        
        if(curSpeed > maxSpeed)
        {
            curSpeed = maxSpeed
        }
    }
    
    func speedDown() {
        curSpeed -= minSpeed / (SPIDER_SPEED_STEP_DIVIDER * SPIDER_SPEED_STEP_DURATION);
        
        if(curSpeed < minSpeed)
        {
            curSpeed = minSpeed
        }
    }
}
