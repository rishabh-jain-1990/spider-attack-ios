//
//  GameScene.swift
//  SpiderAttack
//
//  Created by Rishabh Jain on 8/26/16.
//  Copyright (c) 2016 Bowstring Studio LLP. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let background = SKSpriteNode(imageNamed: "bg.png")
    let blackWeb = SKSpriteNode(imageNamed: "black_web.png")
    let grass = SKSpriteNode(imageNamed: "grass.png")
    var player : Bee!
    var spiderArray = [Spider]()
    
    var spiderWidth : CGFloat = 1
    var countdownValueList = [Int]()
    let gameResultDelegate :GameResult!
    
    var gameState = GameState.NotStarted
    
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Spider   : UInt32 = 0b1       // 1
        static let Bee: UInt32 = 0b10      // 2
    }
    
    init(size :CGSize, gameResultDelegate :GameResult)
    {
        self.gameResultDelegate = gameResultDelegate
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        spiderWidth = size.width / NUM_SPIDERS
        
        background.zPosition = 1
        background.size = size
        background.position = CGPoint(x: (size.width / 2), y: (size.height / 2))
        addChild(background)
        
        reset()
        
        blackWeb.zPosition = 3
        blackWeb.position = CGPoint(x: size.width / 2, y: size.height / 2)
        blackWeb.size = CGSize(width: size.width, height: size.height)
        addChild(blackWeb)
        
        grass.zPosition = 3
        grass.position = CGPoint(x: size.width / 2, y: 20)
        let width = size.width
        grass.size = CGSize(width: width, height: 40)
        addChild(grass)
        
        //        let myLabel = SKLabelNode(fontNamed: "Arial")
        //        myLabel.zPosition = 4
        //        myLabel.text = someNotification
        //        myLabel.fontSize = 20
        //        myLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        //
        //        self.addChild(myLabel)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Spider != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Bee != 0)) {
            // projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
            
            if gameState != GameState.Over
            {
                gameState = GameState.Over
                
                //                removeActionForKey(BG_SOUND_KEY)
                
                gameResultDelegate.gameOver()
            }
        }
        
    }
    
    //    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
    //        print("Hit")
    //        //        projectile.removeFromParent()
    //        //        monster.removeFromParent()
    //    }
    
    func getCountdownValue() -> Int
    {
        if (countdownValueList.isEmpty) {
            for _ in 0..<Int(NUM_SPIDERS)
            {
                var num :Int
                var occurences = 0
                
                repeat{
                    num = Int(arc4random_uniform(10))
                    occurences = countdownValueList.filter {$0 == num}.count
                }while occurences > 2
                countdownValueList.append(num)
            }
        }
        
        return countdownValueList.removeAtIndex(0);
    }
    
    func moveBeeRight() {
        if(player != nil)
        {
            player.moveRight()
        }
    }
    
    func stopMovingBeeRight() {
        if(player != nil)
        {
            player.stopMovingRight()
        }
    }
    
    func moveBeeLeft() {
        if(player != nil)
        {
            player.moveLeft()
        }
    }
    
    func stopMovingBeeLeft() {
        if(player != nil)
        {
            player.stopMovingLeft()
        }
    }
    
    func pause() {
        for i in spiderArray
        {
            i.pause()
        }
        
        player.pause()
        gameState = GameState.Paused
    }
    
    func unpause() {
        for i in spiderArray
        {
            i.unpause()
        }
        
        player.unpause()
        gameState = GameState.Resumed
    }
    
    func reset()
    {
        gameState = GameState.Resumed
        if player == nil
        {
            player = Bee(leftX: 0, rightX: size.width, spiderWidth: spiderWidth)
            player.zPosition = 2
            let width = spiderWidth / BEE_SIZE_DIVIDER
            let aspectRatio = player.size.width / player.size.height
            player.size = CGSize(width: width, height: width / aspectRatio)
            player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
            player.physicsBody?.dynamic = true
            player.physicsBody?.categoryBitMask = PhysicsCategory.Bee
            player.physicsBody?.contactTestBitMask = PhysicsCategory.Spider
            player.physicsBody?.collisionBitMask = PhysicsCategory.None
            player.physicsBody?.usesPreciseCollisionDetection = true
            addChild(player)
        }
        
        player.unpause()
        player.position = CGPoint(x: size.width / 2, y: player.size.height / 2 + 4)
        
        for _ in 0..<spiderArray.count
        {
            let s = spiderArray.removeLast()
            s.line.removeFromParent()
            s.removeFromParent()
        }
        
        for i in 0..<Int(NUM_SPIDERS)
        {
            let x = (spiderWidth / 2) + (spiderWidth * CGFloat(i))
            
            let line = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(spiderWidth / 100, 0))
            line.anchorPoint = CGPointMake(0.5, 1)
            line.zPosition = 4
            line.position.x = x
            line.position.y = size.height
            
            spiderArray.append(Spider(screenHeight: size.height, line: line))
            spiderArray[i].zPosition = 4
            spiderArray[i].position = CGPoint(x: x, y: size.height)
            let aspectRatio = spiderArray[i].size.width/spiderArray[i].size.height
            spiderArray[i].size = CGSize(width: spiderWidth, height: spiderWidth / aspectRatio)
            spiderArray[i].physicsBody = SKPhysicsBody(rectangleOfSize: spiderArray[i].size) // 1
            spiderArray[i].physicsBody?.dynamic = true // 2
            spiderArray[i].physicsBody?.categoryBitMask = PhysicsCategory.Spider // 3
            spiderArray[i].physicsBody?.contactTestBitMask = PhysicsCategory.Bee // 4
            spiderArray[i].physicsBody?.collisionBitMask = PhysicsCategory.None // 5
            spiderArray[i].hidden = true
            addChild(spiderArray[i])
            addChild(line)
            
            spiderArray[i].startTimer(getCountdownValue())
        }
    }
}
