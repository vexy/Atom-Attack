//
//  GameViewController.swift
//  Atom Attack
//
//  Created by Vladislav Jevremović on 11/28/15.
//  Copyright © 2015 Vladislav Jevremovic. All rights reserved.
//

import SpriteKit
import UIKit

internal class GameViewController: UIViewController {

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        prepareScene()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // Scene preparation
    private func prepareScene() {
        guard let skView = view as? SKView else {
            fatalError("Unable to setup Scene")
        }

        //initialize the scene with entire display available
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill

        //debugging and testing info
        skView.showsFPS = true
        //skView.shouldCullNonVisibleNodes = true // INTERESTING !??
        skView.showsNodeCount = true
        skView.showsPhysics = true

        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }
}
