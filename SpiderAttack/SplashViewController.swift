//
//  SplashViewController.swift
//  SpiderAttack
//
//  Created by Rishabh Jain on 9/5/16.
//  Copyright © 2016 Bowstring Studio LLP. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.layer.cornerRadius = 0.5 * playButton.bounds.size.width
        helpButton.layer.cornerRadius = 0.5 * helpButton.bounds.size.width
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
