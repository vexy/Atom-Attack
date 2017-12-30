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

        let scene = GameScene(size: CGSize(width: 2_048, height: 1_536))

        let skView = view as? SKView
        skView?.ignoresSiblingOrder = true

        scene.size = skView?.bounds.size ?? .zero
        scene.scaleMode = .aspectFill

        skView?.presentScene(scene)
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
}
