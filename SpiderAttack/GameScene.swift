//
//  GameScene.swift
//  SpiderAttack
//
//  Created by Rishabh Jain on 8/26/16.
//  Copyright (c) 2016 Bowstring Studio LLP. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
//    override func didMoveToView(view: SKView) {
//        /* Setup your scene here */
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!"
//        myLabel.fontSize = 45
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
//        
//        self.addChild(myLabel)
//    }
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//       /* Called when a touch begins */
//        
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
//        }
//    }
//   
//    override func update(currentTime: CFTimeInterval) {
//        /* Called before each frame is rendered */
//    }
    
    let background = SKSpriteNode(imageNamed: "BG")
    let blackWeb = SKSpriteNode(imageNamed: "BlackWeb")
    let grass = SKSpriteNode(imageNamed: "Grass")
    let player = SKSpriteNode(imageNamed: "Bee")
    let spider = SKSpriteNode(imageNamed: "Spider")
    
    var spiderWidth : CGFloat = 1
    
    override func didMoveToView(view: SKView) {
        
        spiderWidth = size.width / NUM_SPIDERS
        
        background.zPosition = 1
        background.size = CGSize(width: size.width, height: size.height)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)
        
        player.zPosition = 2
        var aspectRatio = player.size.width / player.size.height
        var width = spiderWidth / BEE_SIZE_DIVIDER
        player.size = CGSize(width: width, height: width / aspectRatio)
        player.position = CGPoint(x: size.width / 2, y: player.size.height / 2 + 4)
        addChild(player)
        
        spider.zPosition = 2
        spider.position = CGPoint(x: size.width / 2, y: size.height)
        aspectRatio = spider.size.width/spider.size.height
        spider.size = CGSize(width: spiderWidth, height: spiderWidth / aspectRatio)
        addChild(spider)
        
        downAction()
        
        blackWeb.zPosition = 3
        blackWeb.position = CGPoint(x: size.width / 2, y: size.height / 2)
        blackWeb.size = CGSize(width: size.width, height: size.height)
        addChild(blackWeb)
        
        grass.zPosition = 3
        grass.position = CGPoint(x: size.width / 2, y: 20)
        aspectRatio = size.width/size.height
        width = size.width
        grass.size = CGSize(width: width, height: 40)
        addChild(grass)
        
        let myLabel = SKLabelNode(fontNamed: "Arial")
        myLabel.zPosition = 4
        myLabel.text = someNotification
        myLabel.fontSize = 20
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)
    }
    
    func upAction() {
        let revY = size.height - CGFloat(arc4random_uniform(UInt32(size.height / 2 - spider.size.height))) - spider.size.height / 2;
        let actionRev = SKAction.moveTo(CGPoint(x: spider.position.x, y: revY), duration: NSTimeInterval(revY / ((spiderWidth / SPIDER_SPEED_DIVIDER) * FRAMES_PER_SECOND)));
        spider.runAction(SKAction.sequence([actionRev, SKAction.runBlock(downAction)]))
        player.position.x = player.position.x - (spiderWidth / BEE_SPEED_DIVIDER)
    }
    
    func downAction() {
        let actionRev = SKAction.moveTo(CGPoint(x: spider.position.x, y: spider.size.height / 2), duration: NSTimeInterval(spider.position.y / ((spiderWidth / SPIDER_SPEED_DIVIDER) * FRAMES_PER_SECOND)));
        spider.runAction(SKAction.sequence([actionRev, SKAction.runBlock(upAction)]))
    }
}
