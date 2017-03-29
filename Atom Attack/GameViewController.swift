//
//  GameViewController.swift
//  Atom Attack
//
//  Created by Vladislav Jevremović on 11/28/15.
//  Copyright (c) 2015 Vladislav Jevremovic. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let scene = GameScene(size: CGSize(width: 2048, height: 1536))

        // Configure the view
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        // skView.showsPhysics = true

        // Sprite Kit applies additional optimizations to improve rendering performance
        skView.ignoresSiblingOrder = true

        // Set the scale mode to scale to fit the window
        scene.size = skView.bounds.size
        scene.scaleMode = .aspectFill

        skView.presentScene(scene)
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

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
