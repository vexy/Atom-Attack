//
//  GameScene.swift
//  Atom Attack
//
//  Created by Vladislav Jevremović on 11/28/15.
//  Copyright © 2015 Vladislav Jevremovic. All rights reserved.
//

import AudioToolbox
import QuartzCore
import SpriteKit

internal class GameScene: SKScene, SKPhysicsContactDelegate {
    private lazy var labelScore: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
        label.fontSize = 48
        label.position = CGPoint(x: self.frame.width * 0.55, y: frame.height * 0.9)
        label.zPosition = 1
        label.alpha = 0.8
        label.horizontalAlignmentMode = .right

        return label
    }()
    private lazy var labelLevel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
        label.fontSize = 24
        label.position = CGPoint(x: frame.width * 0.581, y: frame.height * 0.925)
        label.zPosition = 1
        label.alpha = 0.8
        label.horizontalAlignmentMode = .left

        return label
    }()
    
    // Game entities
    private var spawendAtomsCount = 0
    private var mainCore: Core = Core()

    // Gradients and flash action
    private lazy var gradientBackgroundTexture: SKTexture? = {
        SKTexture.textureWithVerticalGradient(
            size: CGSize(),
            topColor: CIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1),
            bottomColor: CIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
    }()
    private lazy var gradientBackground: SKSpriteNode = {
        let node = SKSpriteNode(texture: self.gradientBackgroundTexture)
        node.position = CGPoint(x: 250, y: 500)
        node.zPosition = -1

        return node
    }()
    private lazy var backgroundFlash: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect() )
        node.fillColor = self.backgroundColor
        node.alpha = 0.0
        node.zPosition = 0

        return node
    }()

    // game
    private var score: Int = 0
    private var level: Int = 0
    private var gameOver: Bool = false
    private var canReset: Bool = false

    // MARK: - Private Method
    private func resetScene() {
        gameOver = false
        canReset = false

        score = 0
        level = 0
        spawendAtomsCount = 0

        labelScore.text = "\(score)"
        labelLevel.text = "LEVEL \(level)"
    }

    /// Creates new ray `SKShapeNode` object for the given type parameter
    private func createNewRay(ofType type: Int, alpha: CGFloat) -> SKShapeNode {
        let offsetRadius: CGFloat = 500
        
        let newRay = SKShapeNode(rect: CGRect(x: -10, y: 0, width: 20, height: 5_000))
        newRay.strokeColor = SKColor.clear
        newRay.lineWidth = 0.1
        newRay.position = CGPoint(x: frame.midX + offsetRadius * -sin(alpha),
                                  y: frame.midY * 0.4 + offsetRadius * cos(alpha))
        newRay.zPosition = 2
        newRay.zRotation = alpha
        newRay.userData = ["type": type ]
        
        //finally determine ray color based on the type parameter
        newRay.fillColor = type > 0 ? SKColor(white: 0.2, alpha: 0.2) : SKColor(white: 1.0, alpha: 0.2)
        
        return newRay
    }

    private func doGameOver() {
        gameOver = true
        
        SKTAudio.shared.playSoundEffect("Explosion.mp3")
        labelLevel.text = "GAME OVER :("
        
        spawendAtomsCount = 0
        mainCore.stopSpinning()
        flashBackground()
    }
    
    private func flashBackground() {
        //frist add our new "flashing node"
//        addChild(backgroundFlash)
        
        //animation sequence parameters:
        let oldColor = backgroundFlash.fillColor

        removeAction(forKey: "flash")
        let wait = SKAction.wait(forDuration: 0.05)
        let fadeBackgroundIn        = SKAction.run { self.backgroundFlash.alpha = 1.0 }
        let fadeBackgroundOut       = SKAction.run { self.backgroundFlash.alpha = 0.0 }
        let turnBackgroundRed       = SKAction.run { self.backgroundFlash.fillColor = UIColor.red }
        let turnBackgroundWhite     = SKAction.run { self.backgroundFlash.fillColor = UIColor.white }
        let turnBackgroundOriginal  = SKAction.run { self.backgroundFlash.fillColor = oldColor }
        //construct Flashing animation from above
        let flashSequence           = SKAction.sequence([
            turnBackgroundRed,
            wait,
            turnBackgroundWhite,
            wait,
            turnBackgroundOriginal
        ])
        let repeatFlash             = SKAction.repeat(flashSequence, count: 4)
        let resetAction             = SKAction.run {
            self.backgroundFlash.removeAllActions()
            self.backgroundFlash.removeFromParent()
            self.canReset = true
        }
        
        // fade-in, keep flashing, fade-out, cleanup
        let finalAnimationSequence  = SKAction.sequence([
            fadeBackgroundIn,
            repeatFlash,
            fadeBackgroundOut,
            resetAction
        ])
        
        run(finalAnimationSequence, withKey: "flash")
    }

    private func updateScoreDisplay() {
        labelScore.text = "\(score)"
        labelLevel.text = "LEVEL \(level)"
    }
    
    private func increaseScore() {
        score += 1
        if score > 0 && score % 5 == 0 {
            mainCore.resetHalo()
            level += 1
        }
    }

    private func shouldSpawnNewAtoms() -> Bool {
        //return true if there is less atoms than designated
        return spawendAtomsCount <= maxAtomsForLevel()
    }
    
    

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(white: 185.0 / 255.0, alpha: 1.0)
        
        //setup background
        addChild(gradientBackground)
        addChild(backgroundFlash)

        addChild(labelScore)
        addChild(labelLevel)
        
        
        //initialize and draw Core
        mainCore = Core()
        mainCore.addTo(scene: self)
        mainCore.startSpinning()

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        resetScene()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameOver { mainCore.toggleColorScheme() }
    }
    
    // MARK: - SKSceneDelegate methods
    override func update(_ currentTime: TimeInterval) {
        //exit immediately if the game is over and there's enough atoms already
        guard !gameOver else { return }
        guard spawendAtomsCount < maxAtomsForLevel() else {
            print("Waiting to spawn new atoms...")
            return
        }
        
        //spawn some new atoms
        let newAtomsWave = spawnNewAtoms()
        
        newAtomsWave.forEach{
            let atomSpeed   = getRandomSpeed()
            let delay       = getRandomDelay()
            
            $0.positionIn(scene: self)
            $0.movementSpeed = atomSpeed
            $0.attack(point: mainCore.currentPosition, after: delay)    //..get that core son !!
            
            print("Attacking with speed=\(atomSpeed), delay=\(delay)")
        }
        
        //update our count of spawned atoms
        spawendAtomsCount += newAtomsWave.count
    }
    
    override func didSimulatePhysics() {
        guard !gameOver else { return }
        updateScoreDisplay()
    }

    // MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        // determine colided bodies
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA   //core
            secondBody = contact.bodyB  //atom
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

//        let parent = secondBody.node?.parent
//        print("First body is: \(firstBody.node?.name)")
//        print("Second body is: \(secondBody.node?.name)")
        
        //get bodies as SKShapeNodes
        guard let body1AsShape = firstBody.node as? SKShapeNode else { return }
        guard let body2AsShape = secondBody.node as? SKShapeNode else { return }
        
        //compare their colors (generically -> "computeHitEffect(shape1, shape2)"
        if body1AsShape.fillColor == body2AsShape.fillColor {
            print("COLORS ARE SAME, INCREASE POINTS !!")
            increaseScore()
            mainCore.receiveHit()
            
            //decrease number of spawned atoms due to this hit
            spawendAtomsCount -= 1
            secondBody.node?.removeFromParent()
        } else {
            print("COLORS ARE DIFFERENT, GAME OVER !")
            doGameOver()
        }
    }
}
