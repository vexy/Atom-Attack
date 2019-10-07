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
    private var attackingAtoms = [Atom()]
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

        labelScore.text = "\(score)"
        labelLevel.text = "LEVEL \(level)"
    }

    private func spawnRays() {
        guard !gameOver else { return }
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
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))  //UIHapticFeedback perhaps ?

        let fadeAction = SKAction.fadeAlpha(to: 0.0, duration: 0.2)
        let scaleAction = SKAction.scale(to: 0, duration: 0.2)
        performFlashSequence()
    }
    
    private func performFlashSequence() {
        let oldColor = backgroundFlash.fillColor

        removeAction(forKey: "flash")
        let wait = SKAction.wait(forDuration: 0.05)
        let fadeBackgroundIn = SKAction.run { self.backgroundFlash.alpha = 1.0 }
        let fadeBackgroundOut = SKAction.run { self.backgroundFlash.alpha = 0.0 }
        let turnBackgroundRed = SKAction.run { self.backgroundFlash.fillColor = UIColor.red }
        let turnBackgroundWhite = SKAction.run { self.backgroundFlash.fillColor = UIColor.white }
        let turnBackgroundOriginal = SKAction.run { self.backgroundFlash.fillColor = oldColor }
        let sequenceOfActions = SKAction.sequence([turnBackgroundRed, wait, turnBackgroundWhite, wait, turnBackgroundOriginal])
        let repeatAction = SKAction.repeat(sequenceOfActions, count: 4)
        let resetAction = SKAction.run { self.removeAllActions(); self.canReset = true }
        let flashSequence = SKAction.sequence([fadeBackgroundIn, repeatAction, fadeBackgroundOut, resetAction])
        
        run(flashSequence, withKey: "flash")
    }

    private func doScore() {
        SKTAudio.shared.playSoundEffect("Contact.mp3")

        score += 1
        labelScore.text = "\(score)"

        if score > 0 && score % 5 == 0 {
            level += 1
            labelLevel.text = "LEVEL \(level)"

            var timeToSpawn = 2.5
            switch level {
            case 1:
                timeToSpawn = 2.0
            case 2:
                timeToSpawn = 1.5
            case 3:
                timeToSpawn = 1.0
            case 4:
                timeToSpawn = 0.5
            case let level where level >= 5:
                timeToSpawn = 0.25
            default:
                break
            }

            removeAction(forKey: "spawnRays")
            let spawnRaysAction = SKAction.run { self.spawnRays() }
            let waitAction = SKAction.wait(forDuration: timeToSpawn)
            run(SKAction.repeatForever(SKAction.sequence([spawnRaysAction, waitAction])), withKey: "spawnRays")

            //haloScale = 1.0
        } else {
            //haloScale += 1.0
        }

        //coreHalo.run(SKAction.scale(to: haloScale, duration: 0.2))
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
        if !gameOver {
            // Start the game
            
            //if let action = actionCoreToggleColor {
            //    core.run(action)
            //}
        } else {
            //toggle pause
//            if canReset { resetScene() }
        }
        
        mainCore.toggleColorScheme()
        
//        self.isPaused = !self.isPaused
//        print("Paused state: \(self.isPaused)")
        
        //spawn new particle
        let newParticle = Atom()
        
        newParticle.positionIn(scene: self)
        newParticle.attack(point: mainCore.currentPosition)
        
        //add us to the "bag"
        attackingAtoms.append(newParticle)
    }
    
    // MARK: - SKSceneDelegate methods
    override func update(_ currentTime: TimeInterval) {
//        print("Update logic metod, scene pause state: \(self.isPaused)")
        guard !gameOver else { return }
        
        //check the leveling scale
//        let newAtomsCount = LevelLogic.howManyNewAttoms()
        
        //if there are no attacking atoms, spawn new one(s)
//        spawnNewAtoms(number: newAtomsCount)
        
        //spawnedAtoms.map( $0.attack(core) )
        
        //cleanup of redundant nodes
        //exploded or colided attoms should be removed from scene
        
        //scene.removeExplodedAtoms()
    }
    
    override func didSimulatePhysics() {
        //after a collisions have been done, check for core hit
//        if core.isHit { gameOver = true }
//        print("Physics simulated")
    }
    
    override func didFinishUpdate() {
        //process labels and other static display depending on the state
        
        if gameOver {
            //display game over ?
        } else {
            //something
        }
        
//        print("Update finished...")
//        self.isPaused = true
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

        let parent = secondBody.node?.parent
        print("First body is: \(firstBody.node?.name)")
        print("Second body is: \(secondBody.node?.name)")
        
        //get bodies as SKShapeNodes
        guard let body1AsShape = firstBody.node as? SKShapeNode else { return }
        guard let body2AsShape = secondBody.node as? SKShapeNode else { return }
        
        //comapre their colors
        if body1AsShape.fillColor == body2AsShape.fillColor {
            print("COLORS ARE SAME, INCREASE POINTS !!")
        } else {
            print("COLORS ARE DIFFERENT, GAME OVER !")
            //mainCore.explode()
            mainCore.stopSpinning()
            gameOver = true
        }

        secondBody.node?.removeFromParent()
    }
}
