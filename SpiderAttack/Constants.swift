//
//  Constants.swift
//  SpiderAttack
//
//  Created by Rishabh Jain on 9/1/16.
//  Copyright © 2016 Bowstring Studio LLP. All rights reserved.
//

import Foundation
import SpriteKit

let someNotification = "TEST"
let NUM_SPIDERS : CGFloat = 10.0

// Divide the Spider width by this to get bee width
let BEE_SIZE_DIVIDER : CGFloat = 2.7

let BEE_BITMAP = "Bee bitmap key"

let SPIDER_BITMAP = "spider bitmap key"
let LEVEL_UP_TIME = 90

let ROOKIE_TIME_THRESHOLD = 30
let BEGINNER_TIME_THRESHOLD = 60
let INTERMEDIATE_TIME_THRESHOLD = 120
let EXPERT_TIME_THRESHOLD = 300
let INVINCIBLE_TIME_THRESHOLD = 600

// Divide the spider width by this to get the spider speed
let SPIDER_SPEED_DIVIDER : CGFloat = 16.5

// Divide the minimum spider speed by this to get the increment to spider speed
let SPIDER_SPEED_STEP_DIVIDER = LEVEL_UP_TIME

// Divide the spider width by this to get the spider speed
let BEE_SPEED_DIVIDER : CGFloat = 13

let FRAMES_PER_SECOND  : CGFloat = 40

let GAMES_SERVICES_CLIENT_ID = "68660848152-ie3ofa0ia3gansd4srp0n2on5o6kvdo8.apps.googleusercontent.com"
let MIXPANEL_TOKEN = "f3324dff1554582420f2858e546e10d1"

let HIGHSCORE_KEY = "Highscore value key"
let IS_MUTE_KEY = "Is mute value key"