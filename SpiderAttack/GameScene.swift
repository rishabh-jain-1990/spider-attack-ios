//
//  GameScene.swift
//  SpiderAttack
//
//  Created by Rishabh Jain on 8/26/16.
//  Copyright (c) 2016 Bowstring Studio LLP. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    //    let background = SKSpriteNode(imageNamed: "bg.png")
    //        let background = SKSpriteNode()
    //    let blackWeb = SKSpriteNode(imageNamed: "black_web.png")
    let grass = SKSpriteNode(imageNamed: "grass.png")
    var player : Bee!
    var spiderArray = [Spider]()
    
    var spiderWidth : CGFloat = 1
    var countdownValueList = [Int]()
    let gameResultDelegate :GameResult!
    
    var gameState = GameState.NotStarted
    
    init(size :CGSize, gameResultDelegate :GameResult)
    {
        self.gameResultDelegate = gameResultDelegate
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.clear
        //        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        //        physicsWorld.contactDelegate = self
        
        spiderWidth = size.width / NUM_SPIDERS
        
        //        background.zPosition = 1
        //        background.size = size
        //        background.position = CGPoint(x: (size.width / 2), y: (size.height / 2))
        //        addChild(background)
        
        reset()
        
        //        blackWeb.zPosition = 3
        //        blackWeb.position = CGPoint(x: size.width / 2, y: size.height / 2)
        //        blackWeb.size = CGSize(width: size.width, height: size.height)
        //        addChild(blackWeb)
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewStateChanged), name:NSNotification.Name(rawValue: "paused"), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewStateChanged), name:NSNotification.Name(rawValue: "un-paused"), object:nil)
    }
    
    func viewStateChanged() {
        switch gameState
        {
        case GameState.NotStarted, GameState.Resumed:
            unpause()
        case GameState.Over:
            isPaused = true
        case GameState.Paused:
            pause()
        default: break
        }
    }
    
    //    func didBegin(_ contact: SKPhysicsContact) {
    //
    //        // 1
    //        var firstBody: SKPhysicsBody
    //        var secondBody: SKPhysicsBody
    //        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
    //            firstBody = contact.bodyA
    //            secondBody = contact.bodyB
    //        } else {
    //            firstBody = contact.bodyB
    //            secondBody = contact.bodyA
    //        }
    //
    //        // 2
    //        if ((firstBody.categoryBitMask & PhysicsCategory.Spider != 0) &&
    //            (secondBody.categoryBitMask & PhysicsCategory.Bee != 0)) {
    ////             projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
    //
    //            //            if isPixelFromTextureTransparent((firstBody.node as! SKSpriteNode).texture!, position: contact.contactPoint)
    //            //            {
    //            //                if isPixelFromTextureTransparent((secondBody.node as! SKSpriteNode).texture!, position: contact.contactPoint)
    //            //                {
    //            //                }
    //            //            }
    //
    //            //            performSelector(#selector(gameOver), withObject: nil, afterDelay: Double(0.01))
    //           // gameOver()
    //        }
    //    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if gameState != GameState.Resumed {
            return
        }
        
        for spider in self.spiderArray
        {
            if(spider.frame.intersects(self.player.frame))
            {
                let intersection = spider.frame.intersection(self.player.frame)
                
                let minX = Int(ceil(intersection.minX))
                let maxX = Int(ceil(intersection.maxX))
                
                for i in minX...maxX {
                    for j in Int(ceil(intersection.minY))...Int(ceil(intersection.maxY)) {
                        let scaledSpiderX = (CGFloat(i) - spider.frame.minX) / spider.size.width * spider.getCurrentImage().size.width
                        let scaledSpiderY = (CGFloat(j) - spider.frame.minY) / spider.size.height * spider.getCurrentImage().size.height
                        let scaledPlayerX = (CGFloat(i) - self.player.frame.minX) / self.player.size.width * self.player.getCurrentImage().size.width
                        let scaledPlayerY = (CGFloat(j) - self.player.frame.minY) / self.player.size.height * self.player.getCurrentImage().size.height
                        
                        let playerPoint = CGPoint(x: CGFloat(scaledPlayerX), y: CGFloat(scaledPlayerY))
                        let spiderPoint = CGPoint(x: CGFloat(scaledSpiderX), y: CGFloat(scaledSpiderY))
                        if (spider.getCurrentImage().getPixelColor(pos: spiderPoint).cgColor.components?[3])! / 255 != 0 {
                            if (self.player.getCurrentImage().getPixelColor(pos: playerPoint).cgColor.components?[3])! / 255 != 0 {
                                self.gameOver()
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    func gameOver()
    {
        if gameState != GameState.Over
        {
            
            gameState = GameState.Over
            
            //                removeActionForKey(BG_SOUND_KEY)
            
            gameResultDelegate.gameOver()
        }
    }
    
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
        
        return countdownValueList.remove(at: 0);
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
        
        isPaused = true
        gameState = GameState.Paused
    }
    
    func unpause() {
        for i in spiderArray
        {
            i.unpause()
        }
        
        player.unpause()
        isPaused = false
        gameState = GameState.Resumed
    }
    
    func speedUp()
    {
        for s in spiderArray
        {
            s.speedUp()
        }
    }
    
    func speedDown()
    {
        for s in spiderArray
        {
            s.speedDown()
        }
    }
    
    func reset()
    {
        isPaused = false
        gameState = GameState.Resumed
        if player == nil
        {
            player = Bee(leftX: 0, rightX: size.width, spiderWidth: spiderWidth)
            player.zPosition = 2
            let width = spiderWidth / BEE_SIZE_DIVIDER
            let aspectRatio = player.size.width / player.size.height
            player.size = CGSize(width: width, height: width / aspectRatio)
            //            player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
            //            player.physicsBody?.isDynamic = true
            //            player.physicsBody?.categoryBitMask = PhysicsCategory.Bee
            //            player.physicsBody?.contactTestBitMask = PhysicsCategory.Spider
            //            player.physicsBody?.collisionBitMask = PhysicsCategory.None
            //            player.physicsBody?.usesPreciseCollisionDetection = true
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
            
            let line = SKSpriteNode(color: UIColor.black, size: CGSize(width: spiderWidth / 100,height: 0))
            line.anchorPoint = CGPoint(x: 0.5,y: 1)
            line.zPosition = 4
            line.position.x = x
            line.position.y = size.height
            
            spiderArray.append(Spider(width: spiderWidth, screenHeight: size.height, line: line))
            spiderArray[i].zPosition = 4
            spiderArray[i].position = CGPoint(x: x, y: size.height)
            //            spiderArray[i].physicsBody = SKPhysicsBody(texture: spiderArray[i].texture!, size: spiderArray[i].size) // 1
            //            spiderArray[i].physicsBody?.isDynamic = true // 2
            //            spiderArray[i].physicsBody?.categoryBitMask = PhysicsCategory.Spider // 3
            //            spiderArray[i].physicsBody?.contactTestBitMask = PhysicsCategory.Bee // 4
            //            spiderArray[i].physicsBody?.collisionBitMask = PhysicsCategory.None // 5
            spiderArray[i].isHidden = true
            addChild(spiderArray[i])
            addChild(line)
            
            spiderArray[i].startTimer(countdown: getCountdownValue())
        }
    }
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let xCoordinate = CGFloat(pos.x) * (CGFloat((self.cgImage?.width)!) / self.size.width)
        let yCoordinate = CGFloat(pos.y) * (CGFloat((self.cgImage?.height)!) / self.size.height)
        
        if xCoordinate > CGFloat((self.cgImage?.width)!) || yCoordinate > CGFloat((self.cgImage?.height)!) || xCoordinate < 0 || yCoordinate < 0
        {
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        }
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)!
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(yCoordinate)) + Int(xCoordinate)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
