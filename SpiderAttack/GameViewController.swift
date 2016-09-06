//
//  GameViewController.swift
//  SpiderAttack
//
//  Created by Rishabh Jain on 8/26/16.
//  Copyright (c) 2016 Bowstring Studio LLP. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    
    @IBOutlet weak var gameView: SKView!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var leftArrow: UIButton!
    
    var scene : GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = GameScene(size: view.bounds.size)
        
        // Configure the view.
        let skView = gameView as SKView
        
        skView.showsFPS = true
        
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        //scene.scaleMode =
        
        skView.presentScene(scene)
        
        rightArrow.addTarget(self, action: #selector(moveRight), forControlEvents: .TouchDown)
        
        rightArrow.addTarget(self, action: #selector(stopMovingRight), forControlEvents: [.TouchUpOutside, .TouchUpInside])
        
        leftArrow.addTarget(self, action: #selector(moveLeft), forControlEvents: .TouchDown)
        
        leftArrow.addTarget(self, action: #selector(stopMovingLeft), forControlEvents: [.TouchUpOutside, .TouchUpInside])
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func moveRight() {
        if(scene != nil)
        {
            scene.moveBeeRight()
        }
    }
    
    func stopMovingRight() {
        if(scene != nil)
        {
            scene.stopMovingBeeRight()
        }
    }
    
    func moveLeft() {
        if(scene != nil)
        {
            scene.moveBeeLeft()
        }
    }
    
    func stopMovingLeft() {
        if(scene != nil)
        {
            scene.stopMovingBeeLeft()
        }
    }
}
