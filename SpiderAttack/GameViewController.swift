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
//import Mixpanel
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
    @IBOutlet weak var countdownLabel: UILabel!
    
    var scene : GameScene!
    var gameState = GameState.NotStarted
    var scoreTimer : Timer!
    var timeElapsed = 0
    
    let defaults = UserDefaults.standard
    
    var bgSoundPlayer = AVPlayer()
    var gameOverSoundPlayer = AVPlayer()
    var gcDefaultLeaderBoard = ""
    var gcEnabled = false
    var countdown : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Mixpanel.initialize(token: MIXPANEL_TOKEN)
        
        //        GPGManager.sharedInstance().statusDelegate = self
        //        GIDSignIn.sharedInstance().uiDelegate = self
        
        //        GPGManager.sharedInstance().signInWithClientID(GAMES_SERVICES_CLIENT_ID, silently: true);
        
        var alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: "sound_bg_short", ofType: "mp3")!)
        var playerItem = AVPlayerItem( url:alertSound )
        bgSoundPlayer = AVPlayer(playerItem:playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playBackgroundSound), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: "chew", ofType: "mp3")!)
        playerItem = AVPlayerItem( url:alertSound )
        gameOverSoundPlayer = AVPlayer(playerItem:playerItem)
        
        rightArrow.addTarget(self, action: #selector(moveRight), for: .touchDown)
        
        rightArrow.addTarget(self, action: #selector(stopMovingRight), for: [.touchUpOutside, .touchUpInside])
        
        leftArrow.addTarget(self, action: #selector(moveLeft), for: .touchDown)
        
        leftArrow.addTarget(self, action: #selector(stopMovingLeft), for: [.touchUpOutside, .touchUpInside])
        
        leaderboardImageButton.addTarget(self, action: #selector(showLeaderboard), for: .touchDown)
        leaderboardTextButton.addTarget(self, action: #selector(showLeaderboard), for: .touchDown)
        
        shareTextButton.addTarget(self, action: #selector(shareGame), for: .touchDown)
        shareImageButton.addTarget(self, action: #selector(shareGame), for: .touchDown)
        
        rateImageButton.addTarget(self, action: #selector(rateGame), for: .touchDown)
        rateTextButton.addTarget(self, action: #selector(rateGame), for: .touchDown)
        
        playButton.layer.cornerRadius = 0.5 * playButton.bounds.size.width
        leaderboardImageButton.layer.cornerRadius = 0.5 * leaderboardImageButton.bounds.size.width
        shareImageButton.layer.cornerRadius = 0.5 * shareImageButton.bounds.size.width
        rateImageButton.layer.cornerRadius = 0.5 * rateImageButton.bounds.size.width
        muteImageButton.layer.cornerRadius = 0.5 * muteImageButton.bounds.size.width
        
        muteImageButton.setImage(UIImage(named: defaults.bool(forKey: IS_MUTE_KEY) ? "mute_icon.png" : "unmute_icon.png"), for: UIControlState())
        muteTextButton.setTitle(defaults.bool(forKey: IS_MUTE_KEY) ? "Sound Off" : "Sound On", for: UIControlState())
        
        scoreTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(updateScore), userInfo: nil, repeats: true)
        
        adView.adUnitID = LIVE_AD_UNIT_ID
        adView.rootViewController = self
        adView.load(GADRequest())
        
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGameScene), name:NSNotification.Name(rawValue: "Pause"), object:nil)
        
        self.authenticateLocalPlayer()
    }
    
    override func viewWillLayoutSubviews() {
        if (scene == nil)
        {
            // Configure the view.
            let skView = gameView as GameView
            
            let size = CGSize(width: skView.bounds.size.width, height: skView.bounds.size.height - ((UIDevice.current.userInterfaceIdiom == .phone ? 4 : 2) * leftArrow.bounds.size.height))
            scene = GameScene(size: size, gameResultDelegate: self)
            skView.allowsTransparency = true
            skView.showsFPS = false
            
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
//            scene.scaleMode = SKSceneScaleMode.AspectFill
//            scene.size.width = view.bounds.width
            
            //        scene.size = skView.bounds.size
            skView.presentScene(scene)
//            skView.frameInterval = 2
        }
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool {
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
            scoreboardView.isHidden = false
            adView.isHidden = false
            gameOverLabel.text = "Game Paused"
            currentScoreLabel.text = String(format: "Current Score-  %02d : %02d", arguments:[timeElapsed / 60, timeElapsed % 60])
            
            if(defaults.integer(forKey: HIGHSCORE_KEY) < timeElapsed)
            {
                defaults.set(timeElapsed, forKey: HIGHSCORE_KEY)
                defaults.synchronize()
            }
            
            highScoreLabel.text = String(format: "High Score-  %02d : %02d", arguments:[defaults.integer(forKey: HIGHSCORE_KEY) / 60, defaults.integer(forKey: HIGHSCORE_KEY) % 60])
            playButton.setImage(UIImage(named: "play.png"), for: UIControlState())
        }
        
        scoreTimer.invalidate()
    }
    
    func gameOver()
    {
        gameState = GameState.Over
        bgSoundPlayer.pause()
        
        if !defaults.bool(forKey: IS_MUTE_KEY)
        {
            gameOverSoundPlayer.seek(to: kCMTimeZero)
            gameOverSoundPlayer.play()
        }
        
        if(scene != nil)
        {
            scene.pause()
            scoreboardView.isHidden = false
            adView.isHidden = false
            currentScoreLabel.text = "Game Over"
            currentScoreLabel.text = String(format: "Current Score-  %02d : %02d", arguments:[timeElapsed / 60, timeElapsed % 60])
            if(defaults.integer(forKey: HIGHSCORE_KEY) < timeElapsed)
            {
                defaults.set(timeElapsed, forKey: HIGHSCORE_KEY)
                defaults.synchronize()
            }
            
            let sScore = GKScore(leaderboardIdentifier: gcDefaultLeaderBoard)
            sScore.value = Int64(timeElapsed)
            
            GKScore.report([sScore], withCompletionHandler: { (error: Error?) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                }
            })
            
            highScoreLabel.text = String(format: "High Score-  %02d : %02d", arguments:[defaults.integer(forKey: HIGHSCORE_KEY) / 60, defaults.integer(forKey: HIGHSCORE_KEY) % 60])
            
            playButton.setImage(UIImage(named: "replay.png"), for: UIControlState())
        }
        
        //Mixpanel.mainInstance().track(event: "Score", properties: ["Current Score" : timeElapsed])
        scoreTimer.invalidate()
    }
    
    func playBackgroundSound()
    {
        perform(#selector(
            playSound), with: nil, afterDelay: Double(arc4random_uniform(4) + 2))
    }
    
    func playSound()
    {
        if gameState != GameState.Resumed || defaults.bool(forKey: IS_MUTE_KEY)
        {
            return
        }
        
        bgSoundPlayer.seek(to: kCMTimeZero)
        bgSoundPlayer.play()
    }
    
    func showLeaderboard()
    {
        if gcEnabled
        {
            //            GPGLauncherController.sharedInstance().presentLeaderboardWithLeaderboardId(BEST_TIME_LEADERBOARD_ID)
            
            let gcVC: GKGameCenterViewController = GKGameCenterViewController()
            gcVC.gameCenterDelegate = self
            gcVC.viewState = GKGameCenterViewControllerState.leaderboards
            gcVC.leaderboardIdentifier = gcDefaultLeaderBoard
            self.present(gcVC, animated: true, completion: nil)
        }else{
            let dialog = UIAlertController(title: "Error",
                                           message: "Please sign in to view the loeaderboard",
                                           preferredStyle: UIAlertControllerStyle.alert)
            // Present the dialog.
            present(dialog,
                                  animated: false,
                                  completion: nil)
            
            let delay = 2.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                dialog.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    func shareGame(_ sourceView: UIView)
    {
        if defaults.integer(forKey: HIGHSCORE_KEY) < timeElapsed
        {
            defaults.set(timeElapsed, forKey: HIGHSCORE_KEY)
            defaults.synchronize()
        }
        
        let shareText = String(format: "Try and beat my high score of %02d : %02d at Spider Attack itms-apps://itunes.apple.com/app/id1160146438", arguments:[defaults.integer(forKey: HIGHSCORE_KEY) / 60, defaults.integer(forKey: HIGHSCORE_KEY) % 60])
        
        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
        
        vc.popoverPresentationController?.sourceView = sourceView
        vc.popoverPresentationController?.sourceRect = sourceView.bounds
        
        present(vc, animated: true, completion: nil)
        
    }
    
    func rateGame()
    {
        UIApplication.shared.open(NSURL(string:"itms-apps://itunes.apple.com/app/id1160146438") as! URL, options: [:], completionHandler: nil)
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1 Show login if player is not logged in
                self.pauseGameScene()
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2 Player is already euthenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer: String?, error: Error?) -> Void in
                    if error != nil {
                        print(error ?? "Cannot decode error message")
                    } else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifer!
                    }
                })
                
                
            } else {
                // 3 Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated, disabling game center")
                print(error ?? "Cannot decode error message")
            }
            
        }
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func resumePlay()
    {
        if countdown > 0
        {
            countdownLabel.text = String(countdown)
            countdown = countdown - 1
            perform(#selector(resumePlay), with: nil, afterDelay: 1)
            return
        }
        
        countdownLabel.isHidden = true
        if(scene != nil)
        {
            scene.unpause()
        }
        
        playBackgroundSound()
        scoreTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(updateScore), userInfo: nil, repeats: true)
    }
    
    @IBAction func pauseGame(_ sender: UITapGestureRecognizer) {
        pauseGameScene()
    }
    
    @IBAction func playButtonPressed(_ sender: AnyObject) {
        switch gameState
        {
        case GameState.NotStarted:
            gameState = GameState.Resumed
            
            if(scene != nil)
            {
                scene.unpause()
                scoreboardView.isHidden = true
                adView.isHidden = true
            }
            
            playBackgroundSound()
            scoreTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(updateScore), userInfo: nil, repeats: true)
        case GameState.Paused:
            // TODO: Start countdown
            countdown = 3
            countdownLabel.isHidden = false
            gameState = GameState.Resumed
            scoreboardView.isHidden = true
            adView.isHidden = true
            resumePlay()
        case GameState.Over:
            gameState = GameState.Resumed
            
            if(scene != nil)
            {
                scene.reset()
                scoreboardView.isHidden = true
                adView.isHidden = true
            }
            
            timeElapsed = 0
            playBackgroundSound()
            scoreLabel.text = String(format: "Score-  %02d : %02d", arguments:[timeElapsed / 60, timeElapsed % 60])
            scoreTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(updateScore), userInfo: nil, repeats: true)
        case GameState.Resumed:
            break
        default:
            break
        }
    }
    
    @IBAction func muteButtonPressed(_ sender: AnyObject) {
        let isMute = !defaults.bool(forKey: IS_MUTE_KEY)
        defaults.set(isMute, forKey: IS_MUTE_KEY)
        muteImageButton.setImage(UIImage(named: isMute ? "mute_icon.png" : "unmute_icon.png"), for: UIControlState())
        muteTextButton.setTitle(defaults.bool(forKey: IS_MUTE_KEY) ? "Sound Off" : "Sound On", for: UIControlState())
    }
}
