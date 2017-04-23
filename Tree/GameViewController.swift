//
//  GameViewController.swift
//  Tree
//
//  Created by Ruohan Liu on 17/04/17.
//  Copyright © 2017 Ruohan Liu. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let gameScene = GameSceneFive()
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        gameScene.size = self.view.bounds.size
        skView.presentScene(gameScene)
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
