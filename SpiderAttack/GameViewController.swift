//
//  GameViewController.swift
//  SpiderAttack
//
//  Created by Rishabh Jain on 8/26/16.
//  Copyright (c) 2016 Bowstring Studio LLP. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import Mixpanel
import GoogleMobileAds

class GameViewController: UIViewController, GameResult, GPGStatusDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var gameView: GameView!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var scoreboardView: UIView!
    @IBOutlet weak var gameOverLabel: UILabel!
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
    @IBOutlet weak var adView: GADBannerView!
    
    var scene : GameScene!
    var gameState = GameState.NotStarted
    var scoreTimer : NSTimer!
    var timeElapsed = 0
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var bgSoundPlayer = AVPlayer()
    var gameOverSoundPlayer = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Mixpanel.initialize(token: MIXPANEL_TOKEN)
        
        GPGManager.sharedInstance().statusDelegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        
        GPGManager.sharedInstance().signInWithClientID(GAMES_SERVICES_CLIENT_ID, silently: true);
        
        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("sound_bg_short", ofType: "mp3")!)
        var playerItem = AVPlayerItem( URL:alertSound )
        bgSoundPlayer = AVPlayer(playerItem:playerItem)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playBackgroundSound), name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        
        alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("chew", ofType: "mp3")!)
        playerItem = AVPlayerItem( URL:alertSound )
        gameOverSoundPlayer = AVPlayer(playerItem:playerItem)
        
        scene = GameScene(size: view.bounds.size, gameResultDelegate: self)
        
        // Configure the view.
        let skView = gameView as GameView
        
        skView.showsFPS = true
        
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        //scene.scaleMode =
        
        skView.presentScene(scene)
        skView.frameInterval = 2
        
        rightArrow.addTarget(self, action: #selector(moveRight), forControlEvents: .TouchDown)
        
        rightArrow.addTarget(self, action: #selector(stopMovingRight), forControlEvents: [.TouchUpOutside, .TouchUpInside])
        
        leftArrow.addTarget(self, action: #selector(moveLeft), forControlEvents: .TouchDown)
        
        leftArrow.addTarget(self, action: #selector(stopMovingLeft), forControlEvents: [.TouchUpOutside, .TouchUpInside])
        
        signInImageButton.addTarget(self, action: #selector(signInClicked), forControlEvents: .TouchDown)
        signInTextButton.addTarget(self, action: #selector(signInClicked), forControlEvents: .TouchDown)
        
        leaderboardImageButton.addTarget(self, action: #selector(showLeaderboard), forControlEvents: .TouchDown)
        leaderboardTextButton.addTarget(self, action: #selector(showLeaderboard), forControlEvents: .TouchDown)
        
        shareTextButton.addTarget(self, action: #selector(shareGame), forControlEvents: .TouchDown)
        shareImageButton.addTarget(self, action: #selector(shareGame), forControlEvents: .TouchDown)
        
        rateImageButton.addTarget(self, action: #selector(rateGame), forControlEvents: .TouchDown)
        rateTextButton.addTarget(self, action: #selector(rateGame), forControlEvents: .TouchDown)
        
        playButton.layer.cornerRadius = 0.5 * playButton.bounds.size.width
        signInImageButton.layer.cornerRadius = 0.5 * signInImageButton.bounds.size.width
        leaderboardImageButton.layer.cornerRadius = 0.5 * leaderboardImageButton.bounds.size.width
        shareImageButton.layer.cornerRadius = 0.5 * shareImageButton.bounds.size.width
        rateImageButton.layer.cornerRadius = 0.5 * rateImageButton.bounds.size.width
        muteImageButton.layer.cornerRadius = 0.5 * muteImageButton.bounds.size.width
        
        muteImageButton.setImage(UIImage(named: defaults.boolForKey(IS_MUTE_KEY) ? "mute_icon.png" : "unmute_icon.png"), forState: UIControlState.Normal)
        updateSignInButton()
        
        //        signInTextButton.titleLabel!.font =  UIFont(name: "creepycrawlers", size: 20)
        scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(updateScore), userInfo: nil, repeats: true)
        
        adView.adUnitID = LIVE_AD_UNIT_ID
        adView.rootViewController = self
        adView.loadRequest(GADRequest())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(pauseGameScene), name:"Pause", object:nil)
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
        
        if timeElapsed >= LEVEL_UP_TIME && CGFloat(timeElapsed % LEVEL_UP_TIME) < SPIDER_SPEED_STEP_DURATION
        {
            scene.speedUp();
        }
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
    
    func pauseGameScene()
    {
        if gameState == GameState.Over
        {
            return
        }
        
        gameState = GameState.Paused
        
        if scene != nil
        {
            scene.pause()
            scoreboardView.hidden = false
            adView.hidden = false
            gameOverLabel.text = "Game Paused"
            currentScoreLabel.text = String(format: "Current Score-  %02d : %02d", arguments:[timeElapsed / 60, timeElapsed % 60])
            
            if(defaults.integerForKey(HIGHSCORE_KEY) < timeElapsed)
            {
                defaults.setInteger(timeElapsed, forKey: HIGHSCORE_KEY)
                defaults.synchronize()
            }
            
            highScoreLabel.text = String(format: "High Score-  %02d : %02d", arguments:[defaults.integerForKey(HIGHSCORE_KEY) / 60, defaults.integerForKey(HIGHSCORE_KEY) % 60])
            playButton.setImage(UIImage(named: "play.png"), forState: UIControlState.Normal)
        }
        
        scoreTimer.invalidate()
    }
    
    func gameOver()
    {
        gameState = GameState.Over
        bgSoundPlayer.pause()
        
        if !defaults.boolForKey(IS_MUTE_KEY)
        {
            gameOverSoundPlayer.seekToTime(kCMTimeZero)
            gameOverSoundPlayer.play()
        }
        
        if(scene != nil)
        {
            scene.pause()
            scoreboardView.hidden = false
            adView.hidden = false
            currentScoreLabel.text = "Game Over"
            currentScoreLabel.text = String(format: "Current Score-  %02d : %02d", arguments:[timeElapsed / 60, timeElapsed % 60])
            if(defaults.integerForKey(HIGHSCORE_KEY) < timeElapsed)
            {
                defaults.setInteger(timeElapsed, forKey: HIGHSCORE_KEY)
                defaults.synchronize()
            }
            
            highScoreLabel.text = String(format: "High Score-  %02d : %02d", arguments:[defaults.integerForKey(HIGHSCORE_KEY) / 60, defaults.integerForKey(HIGHSCORE_KEY) % 60])
            
            playButton.setImage(UIImage(named: "replay.png"), forState: UIControlState.Normal)
        }
        
        Mixpanel.mainInstance().track(event: "Score",
                                      properties: ["Current Score" : timeElapsed])
        scoreTimer.invalidate()
    }
    
    func playBackgroundSound()
    {
        performSelector(#selector(
            playSound), withObject: nil, afterDelay: Double(arc4random_uniform(4) + 2))
    }
    
    func playSound()
    {
        if gameState != GameState.Resumed || defaults.boolForKey(IS_MUTE_KEY)
        {
            return
        }
        
        bgSoundPlayer.seekToTime(kCMTimeZero)
        bgSoundPlayer.play()
    }
    
    func signInClicked()
    {
        if !GPGManager.sharedInstance().signedIn
        {
            GPGManager.sharedInstance().signInWithClientID(GAMES_SERVICES_CLIENT_ID, silently: false);
        }
        else
        {
            GPGManager.sharedInstance().signOut()
            updateSignInButton()
        }
    }
    
    func updateSignInButton() {
        signInImageButton.setImage(UIImage(named: GPGManager.sharedInstance().signedIn ? "controller_filled.png" : "controller.png"), forState: UIControlState.Normal)
        signInTextButton.setTitle(GPGManager.sharedInstance().signedIn ? "Sign Out" : "Sign In", forState: UIControlState.Normal)
    }
    
    func didFinishGamesSignInWithError(error: NSError!) {
        if error != nil
        {
            print(error.description)
        }
        
        updateSignInButton();
    }
    
    func didFinishGamesSignOutWithError(error: NSError!) {
        if error != nil
        {
            print(error.description)
        }
        updateSignInButton();
    }
    
    func didFinishGoogleAuthWithError(error: NSError!) {
        if error != nil
        {
            print(error.description)
        }
        updateSignInButton();
    }
    
    func showLeaderboard()
    {
        GPGLauncherController.sharedInstance().presentLeaderboardWithLeaderboardId(BEST_TIME_LEADERBOARD_ID)
    }
    
    func shareGame()
    {
        if(defaults.integerForKey(HIGHSCORE_KEY) < timeElapsed)
        {
            defaults.setInteger(timeElapsed, forKey: HIGHSCORE_KEY)
            defaults.synchronize()
        }
        
        let shareText = String(format: "Try and beat my high score of %02d : %02d at Spider Attack https://goo.gl/bOhbH3", arguments:[defaults.integerForKey(HIGHSCORE_KEY) / 60, defaults.integerForKey(HIGHSCORE_KEY) % 60])

        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func rateGame()
    {
        UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id959379869")!)
    }
    
    @IBAction func pauseGame(sender: UITapGestureRecognizer) {
        pauseGameScene()
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
                adView.hidden = true
            }
            
            playBackgroundSound()
            scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(updateScore), userInfo: nil, repeats: true)
        case GameState.Paused:
            // TODO: Start countdown
            gameState = GameState.Resumed
            
            if(scene != nil)
            {
                scene.unpause()
                scoreboardView.hidden = true
                adView.hidden = true
            }
            
            playBackgroundSound()
            scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(updateScore), userInfo: nil, repeats: true)
        case GameState.Over:
            gameState = GameState.Resumed
            
            if(scene != nil)
            {
                scene.reset()
                scoreboardView.hidden = true
                adView.hidden = true
            }
            
            timeElapsed = 0
            playBackgroundSound()
            scoreLabel.text = String(format: "Score-  %02d : %02d", arguments:[timeElapsed / 60, timeElapsed % 60])
            scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(updateScore), userInfo: nil, repeats: true)
        case GameState.Resumed:
            break
        default:
            break
        }
    }
    
    @IBAction func muteButtonPressed(sender: AnyObject) {
        let isMute = !defaults.boolForKey(IS_MUTE_KEY)
        defaults.setBool(isMute, forKey: IS_MUTE_KEY)
        muteImageButton.setImage(UIImage(named: isMute ? "mute_icon.png" : "unmute_icon.png"), forState: UIControlState.Normal)
    }
}
