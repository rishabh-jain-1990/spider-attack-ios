//
//  GameViewController.swift
//  SpiderAttack
//
//  Created by Rishabh Jain on 8/26/16.
//  Copyright (c) 2016 Bowstring Studio LLP. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameResult {
    
    struct GameState {
        static let Resumed      : UInt32 = 0
        static let Over   : UInt32 = 0b1       // 1
        static let Paused: UInt32 = 0b10      // 2
        static let NotStarted: UInt32 = 0b100      // 3
    }
    
    @IBOutlet weak var gameView: SKView!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
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
    var gameState = GameState.NotStarted
    var scoreTimer : NSTimer!
    var timeElapsed = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = GameScene(size: view.bounds.size, gameResultDelegate: self)
        
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
        
        //        signInTextButton.titleLabel!.font =  UIFont(name: "creepycrawlers", size: 20)
        scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(updateScore), userInfo: nil, repeats: true)
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
    
    func updateScore()
    {
        timeElapsed += 1
        scoreLabel.text = String(format: "Score-  %02d : %02d", arguments:[timeElapsed / 60, timeElapsed % 60])
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
    
    func pauseGame()
    {
        gameState = GameState.Paused
        
        if(scene != nil)
        {
            scene.pause()
            scoreboardView.hidden = false
            currentScoreLabel.text = "Game Paused"
            currentScoreLabel.text = String(format: "Current Score-  %02d : %02d", arguments:[timeElapsed / 60, timeElapsed % 60])
            playButton.setImage(UIImage(named: "play.png"), forState: UIControlState.Normal)
        }
        
        scoreTimer.invalidate()
    }
    
    func gameOver()
    {
        gameState = GameState.Over
        if(scene != nil)
        {
            scene.pause()
            scoreboardView.hidden = false
            currentScoreLabel.text = "Game Over"
            currentScoreLabel.text = String(format: "Current Score-  %02d : %02d", arguments:[timeElapsed / 60, timeElapsed % 60])
            playButton.setImage(UIImage(named: "replay.png"), forState: UIControlState.Normal)
        }
        
        scoreTimer.invalidate()
    }
    
    @IBAction func pauseGame(sender: UITapGestureRecognizer) {
        pauseGame()
    }
    
    @IBAction func playButtonPressed(sender: AnyObject) {
        switch gameState
        {
        case GameState.NotStarted:
            gameState = GameState.Resumed
            
            if(scene != nil)
            {
                scene.unpause()
                scoreboardView.hidden = true
            }
            
            scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(updateScore), userInfo: nil, repeats: true)
        case GameState.Paused:
            // TODO: Start countdown
            gameState = GameState.Resumed
            
            if(scene != nil)
            {
                scene.unpause()
                scoreboardView.hidden = true
            }
            
            scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(updateScore), userInfo: nil, repeats: true)
        case GameState.Over:
            gameState = GameState.Resumed
            
            if(scene != nil)
            {
                scene.reset()
                scoreboardView.hidden = true
            }
            
            timeElapsed = 0
            scoreLabel.text = String(format: "Score-  %02d : %02d", arguments:[timeElapsed / 60, timeElapsed % 60])
            scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(updateScore), userInfo: nil, repeats: true)
        case GameState.Resumed:
            break
        default:
            break
        }
    }
}
