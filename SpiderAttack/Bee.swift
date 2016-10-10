//
//  Bee.swift
//  BeeAttack
//
//  Created by Rishabh Jain on 9/1/16.
//  Copyright © 2016 Bowstring Studio LLP. All rights reserved.
//

import Foundation
import SpriteKit

class Bee : SKSpriteNode
{
    struct MovementDirection {
        static let None      : UInt32 = 0
        static let Right   : UInt32 = 0b1       // 1
        static let Left: UInt32 = 0b10      // 2
    }
    
    private static var beeTextureArray = [SKTexture]()
    private static var beeImageArray = [UIImage]()
    
    var currentImageIndex = 0;
    var movementDirection = MovementDirection.None
    
    let leftX :CGFloat
    let rightX :CGFloat
    let spiderWidth :CGFloat
    
    init(leftX : CGFloat, rightX: CGFloat, spiderWidth: CGFloat)
    {
        self.leftX = leftX
        self.rightX = rightX
        self.spiderWidth = spiderWidth
        
        let texture = SKTexture(imageNamed: "bee_00000")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        if Bee.beeTextureArray.isEmpty
        {
            
            Bee.beeImageArray.append(UIImage(named: "bee_00000")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00001")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00002")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00003")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00004")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00005")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00006")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00007")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00008")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00009")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00010")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00011")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00012")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00013")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00014")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00015")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00016")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00017")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00018")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00019")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00020")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00021")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00022")!)
            Bee.beeImageArray.append(UIImage(named: "bee_00023")!)
            
            for image in Bee.beeImageArray
            {
                Bee.beeTextureArray.append(SKTexture(image: image))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveRight() {
        
        movementDirection = MovementDirection.Right
        removeAllActions()
        let duration = TimeInterval((rightX - position.x) / ((spiderWidth / BEE_SPEED_DIVIDER) * FRAMES_PER_SECOND))
        run(SKAction.moveTo(x: rightX, duration: duration))
        
        perform(#selector(changeImage), with: nil, afterDelay: Double(1/FRAMES_PER_SECOND))
    }
    
    func stopMovingRight() {
        if movementDirection == MovementDirection.Right
        {
            movementDirection = MovementDirection.None
            removeAllActions()
        }
        
    }
    
    func moveLeft() {
        movementDirection = MovementDirection.Left
        removeAllActions()
        let duration = TimeInterval((position.x - leftX) / ((spiderWidth / BEE_SPEED_DIVIDER) * FRAMES_PER_SECOND))
        run(SKAction.moveTo(x: leftX, duration: duration))
        
        perform(#selector(changeImage), with: nil, afterDelay: Double(1/FRAMES_PER_SECOND))
    }
    
    func stopMovingLeft() {
        if movementDirection == MovementDirection.Left
        {
            movementDirection = MovementDirection.None
            removeAllActions()
        }
    }
    
    func changeImage()
    {
        if isPaused == true
        {
            return
        }
        
        switch movementDirection
        {
        case MovementDirection.Right:
            texture = getNextImage()
            perform(#selector(changeImage), with: nil, afterDelay: Double(1/FRAMES_PER_SECOND))
        case MovementDirection.Left:
            texture = getPreviousImage()
            perform(#selector(changeImage), with: nil, afterDelay: Double(1/FRAMES_PER_SECOND))
        case MovementDirection.None: break
        default: break
        }
    }
    
    func getNextImage() -> SKTexture
    {
        currentImageIndex += 1
        currentImageIndex = currentImageIndex > 23 ? 0 : currentImageIndex
        
        return Bee.beeTextureArray[currentImageIndex]
    }
    
    func getPreviousImage() -> SKTexture
    {
        currentImageIndex -= 1
        currentImageIndex = currentImageIndex < 0 ? 23 : currentImageIndex
        
        return Bee.beeTextureArray[currentImageIndex]
    }
    
    func getCurrentImage() -> UIImage
    {
        return Bee.beeImageArray[currentImageIndex]
    }
    
    func pause() {
        isPaused = true
    }
    
    func unpause() {
        isPaused = false
        changeImage()
    }
}
