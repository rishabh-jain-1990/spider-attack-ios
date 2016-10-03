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
import GameKit

class GameViewController: UIViewController, GameResult, GKGameCenterControllerDelegate {
    
    @IBOutlet weak var gameView: GameView!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var scoreboardView: UIView!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var leaderboardImageButton: UIButton!
    @IBOutlet weak var rateImageButton: UIButton!
    @IBOutlet weak var shareImageButton: UIButton!
    @IBOutlet weak var shareTextButton: UIButton!
    @IBOutlet weak var rateTextButton: UIButton!
    @IBOutlet weak var leaderboardTextButton: UIButton!
    @IBOutlet weak var muteTextButton: UIButton!
    @IBOutlet weak var muteImageButton: UIButton!
    @IBOutlet weak var adView: GADBannerView!
    
    var scene : GameScene!
    var gameState = GameState.NotStarted
    var scoreTimer : NSTimer!
    var timeElapsed = 0
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var bgSoundPlayer = AVPlayer()
    var gameOverSoundPlayer = AVPlayer()
    var gcDefaultLeaderBoard = ""
    var gcEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Mixpanel.initialize(token: MIXPANEL_TOKEN)
        
        //        GPGManager.sharedInstance().statusDelegate = self
        //        GIDSignIn.sharedInstance().uiDelegate = self
        
        //        GPGManager.sharedInstance().signInWithClientID(GAMES_SERVICES_CLIENT_ID, silently: true);
        
        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("sound_bg_short", ofType: "mp3")!)
        var playerItem = AVPlayerItem( URL:alertSound )
        bgSoundPlayer = AVPlayer(playerItem:playerItem)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playBackgroundSound), name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        
        alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("chew", ofType: "mp3")!)
        playerItem = AVPlayerItem( URL:alertSound )
        gameOverSoundPlayer = AVPlayer(playerItem:playerItem)
        
        rightArrow.addTarget(self, action: #selector(moveRight), forControlEvents: .TouchDown)
        
        rightArrow.addTarget(self, action: #selector(stopMovingRight), forControlEvents: [.TouchUpOutside, .TouchUpInside])
        
        leftArrow.addTarget(self, action: #selector(moveLeft), forControlEvents: .TouchDown)
        
        leftArrow.addTarget(self, action: #selector(stopMovingLeft), forControlEvents: [.TouchUpOutside, .TouchUpInside])
        
        leaderboardImageButton.addTarget(self, action: #selector(showLeaderboard), forControlEvents: .TouchDown)
        leaderboardTextButton.addTarget(self, action: #selector(showLeaderboard), forControlEvents: .TouchDown)
        
        shareTextButton.addTarget(self, action: #selector(shareGame), forControlEvents: .TouchDown)
        shareImageButton.addTarget(self, action: #selector(shareGame), forControlEvents: .TouchDown)
        
        rateImageButton.addTarget(self, action: #selector(rateGame), forControlEvents: .TouchDown)
        rateTextButton.addTarget(self, action: #selector(rateGame), forControlEvents: .TouchDown)
        
        playButton.layer.cornerRadius = 0.5 * playButton.bounds.size.width
        leaderboardImageButton.layer.cornerRadius = 0.5 * leaderboardImageButton.bounds.size.width
        shareImageButton.layer.cornerRadius = 0.5 * shareImageButton.bounds.size.width
        rateImageButton.layer.cornerRadius = 0.5 * rateImageButton.bounds.size.width
        muteImageButton.layer.cornerRadius = 0.5 * muteImageButton.bounds.size.width
        
        muteImageButton.setImage(UIImage(named: defaults.boolForKey(IS_MUTE_KEY) ? "mute_icon.png" : "unmute_icon.png"), forState: UIControlState.Normal)
        muteTextButton.setTitle(defaults.boolForKey(IS_MUTE_KEY) ? "Sound Off" : "Sound On", forState: UIControlState.Normal)
        
        scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(updateScore), userInfo: nil, repeats: true)
        
        adView.adUnitID = LIVE_AD_UNIT_ID
        adView.rootViewController = self
        adView.loadRequest(GADRequest())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(pauseGameScene), name:"Pause", object:nil)
        
        self.authenticateLocalPlayer()
    }
    
    override func viewWillLayoutSubviews() {
        if (scene == nil)
        {
            // Configure the view.
            let skView = gameView as GameView
            
            let size = CGSize(width: skView.bounds.size.width, height: skView.bounds.size.height - ((UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 4 : 2) * leftArrow.bounds.size.height))
            scene = GameScene(size: size, gameResultDelegate: self)
            skView.allowsTransparency = true
            skView.showsFPS = true
            
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
//            scene.scaleMode = SKSceneScaleMode.AspectFill
//            scene.size.width = view.bounds.width
            
            //        scene.size = skView.bounds.size
            skView.presentScene(scene)
            skView.frameInterval = 2
        }
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
            
            let sScore = GKScore(leaderboardIdentifier: gcDefaultLeaderBoard)
            sScore.value = Int64(timeElapsed)
            
            GKScore.reportScores([sScore], withCompletionHandler: { (error: NSError?) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("Score submitted")
                    
                }
            })
            
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
    
    func showLeaderboard()
    {
        if gcEnabled
        {
            //            GPGLauncherController.sharedInstance().presentLeaderboardWithLeaderboardId(BEST_TIME_LEADERBOARD_ID)
            
            let gcVC: GKGameCenterViewController = GKGameCenterViewController()
            gcVC.gameCenterDelegate = self
            gcVC.viewState = GKGameCenterViewControllerState.Leaderboards
            gcVC.leaderboardIdentifier = gcDefaultLeaderBoard
            self.presentViewController(gcVC, animated: true, completion: nil)
        }else{
            let dialog = UIAlertController(title: "Error",
                                           message: "Please sign in to view the loeaderboard",
                                           preferredStyle: UIAlertControllerStyle.Alert)
            // Present the dialog.
            presentViewController(dialog,
                                  animated: false,
                                  completion: nil)
            
            let delay = 2.0 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                dialog.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    func shareGame(sourceView: UIView)
    {
        if defaults.integerForKey(HIGHSCORE_KEY) < timeElapsed
        {
            defaults.setInteger(timeElapsed, forKey: HIGHSCORE_KEY)
            defaults.synchronize()
        }
        
        let shareText = String(format: "Try and beat my high score of %02d : %02d at Spider Attack https://goo.gl/bOhbH3", arguments:[defaults.integerForKey(HIGHSCORE_KEY) / 60, defaults.integerForKey(HIGHSCORE_KEY) % 60])
        
        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
        
        vc.popoverPresentationController?.sourceView = sourceView
        vc.popoverPresentationController?.sourceRect = sourceView.bounds
        
        presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func rateGame()
    {
        UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id1160146438")!)
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1 Show login if player is not logged in
                self.presentViewController(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.authenticated) {
                // 2 Player is already euthenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifer: String?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifer!
                    }
                })
                
                
            } else {
                // 3 Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated, disabling game center")
                print(error)
            }
            
        }
        
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
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
        muteTextButton.setTitle(defaults.boolForKey(IS_MUTE_KEY) ? "Sound Off" : "Sound On", forState: UIControlState.Normal)
    }
}
