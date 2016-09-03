//
//  GameScene.swift
//  SpiderAttack
//
//  Created by Rishabh Jain on 8/26/16.
//  Copyright (c) 2016 Bowstring Studio LLP. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    let background = SKSpriteNode(imageNamed: "BG")
    let blackWeb = SKSpriteNode(imageNamed: "BlackWeb")
    let grass = SKSpriteNode(imageNamed: "Grass")
    let player = SKSpriteNode(imageNamed: "Bee")
    var spiderArray = [Spider]()
    
    var spiderWidth : CGFloat = 1
    var countdownValueList = [Int]()
    
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
        
        spiderArray.removeAll()
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
            aspectRatio = spiderArray[i].size.width/spiderArray[i].size.height
            spiderArray[i].size = CGSize(width: spiderWidth, height: spiderWidth / aspectRatio)
            addChild(spiderArray[i])
            addChild(line)
            
            spiderArray[i].startTimer(getCountdownValue())
        }
        
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
}
