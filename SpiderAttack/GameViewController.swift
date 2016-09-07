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
    
    @IBOutlet weak var scoreboardView: UIView!
    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var signInImageButton: UIButton!
    @IBOutlet weak var leaderboardImageButton: UIButton!
    @IBOutlet weak var rateImageButton: UIButton!
    @IBOutlet weak var shareImageButton: UIButton!
    @IBOutlet weak var shareTextButton: UIButton!
    @IBOutlet weak var rateTextButton: UIButton!
    @IBOutlet weak var signInTextButton: UIButton!
    @IBOutlet weak var leaderboardTextButton: UIButton!
    @IBOutlet weak var muteImageButton: UIButton!
    
    
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
        
        playButton.layer.cornerRadius = 0.5 * playButton.bounds.size.width
        signInImageButton.layer.cornerRadius = 0.5 * signInImageButton.bounds.size.width
        leaderboardImageButton.layer.cornerRadius = 0.5 * leaderboardImageButton.bounds.size.width
        shareImageButton.layer.cornerRadius = 0.5 * shareImageButton.bounds.size.width
        rateImageButton.layer.cornerRadius = 0.5 * rateImageButton.bounds.size.width
        muteImageButton.layer.cornerRadius = 0.5 * muteImageButton.bounds.size.width
        
//        signInTextButton.titleLabel!.font =  UIFont(name: "creepycrawlers.ttf", size: 20)

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
