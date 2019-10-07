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
    
//    private let backgroundColor = SKColor(white: 185.0 / 255.0, alpha: 1.0)
    
    private var ray: SKShapeNode?
    private var particle: SKShapeNode?
    
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
    private var rays: SKNode = SKNode()

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

    private var actionCoreToggleColor: SKAction?

    // game
    private var score: Int = 0
    private var level: Int = 0
    private var gameOver: Bool = false
    private var canReset: Bool = false
    
    // entities declaration (array of attacking atoms)
    private var attackingAtoms = [Core()]

    // MARK: - Private Methods
    private func setupToggle() {
        actionCoreToggleColor = SKAction.run { [unowned self] in
//            guard let coreType = self.core.userData?["type"] as? Int else { return }
            
            /*
            let whiteFactor = CGFloat(coreType > 0 ? 1 : 0)
            self.core.fillColor = SKColor(white: whiteFactor, alpha: 1.0)
            self.core.strokeColor = SKColor(white: whiteFactor, alpha: 1.0)
            self.core.children.forEach{ ($0 as? SKShapeNode)?.fillColor = SKColor(white: whiteFactor, alpha: 1.0) }
            */
            
            //toggle core type
//            self.core.userData?["type"] = 1 - coreType
        }
    }

    private func resetScene() {
        gameOver = false
        canReset = false

        score = 0
        level = 0

        labelScore.text = "\(score)"
        labelLevel.text = "LEVEL \(level)"
        

        let spawnRaysAction = SKAction.run { self.spawnRays() }
        let waitAction = SKAction.wait(forDuration: 2.0)
        let finalSequence = [spawnRaysAction, waitAction]
        run(SKAction.repeatForever(SKAction.sequence(finalSequence)), withKey: "spawnRays")
    }

    private func spawnRays() {
        guard !gameOver else { return }
        let alpha = CGFloat.random(min: -CGFloat.pi / 6, max: CGFloat.pi / 6)
        
        //randomize type
        let typeValue = Int.random(2)
        
        //setup ray & particle
        let newRay = createNewRay(ofType: typeValue, alpha: alpha)
//        let newParticle = createNewParticle(ofType: typeValue)
        
        //update collections
       // newRay.addChild(newParticle)
        rays.addChild(newRay)
            
        //update class references
        self.ray = newRay
        //self.particle = newParticle
            
        ray!.run(SKAction.sequence([SKAction.moveBy(x: 2_000 * sin(alpha), y: -2_000 * cos(alpha), duration: 5),
                                       SKAction.removeFromParent()]))
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

        rays.removeAllChildren()
//        core.removeAction(forKey: "coreRotation")

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
        
        addChild(rays)
        addChild(gradientBackground)
        addChild(backgroundFlash)

        addChild(labelScore)
        addChild(labelLevel)
        //setupCore()
        setupToggle()

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        resetScene()
        print("Did move event")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameOver {
            // Start the game
            
            //if let action = actionCoreToggleColor {
            //    core.run(action)
            //}
        } else {
            if canReset { resetScene() }
        }
    }
    
    // MARK: - SKSceneDelegate methods
    override func update(_ currentTime: TimeInterval) {
        print("Update logic metod, scene pause state: \(self.isPaused)")
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
        print("Physics simulated")
    }
    
    override func didFinishUpdate() {
        //process labels and other static display depending on the state
        
        if gameOver {
            //display game over ?
        } else {
            //something
        }
        
        print("Update finished, pausing immediatelly")
//        self.isPaused = true
    }
    

    // MARK: - SKPhysicsContactDelegate

    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        // determine colided bodies
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        let parent = secondBody.node?.parent
        
        print("First body is: \(firstBody.node?.name)")
        print("Second body is: \(secondBody.node?.name)")

        /*
        if firstBody.categoryBitMask & coreCategory == coreCategory {
            if let type1 = core.userData?["type"] as? Int {
                if let type2 = parent?.userData?["type"] as? Int {
                    
                    // no collisions while shaking
                    if let particlePhysicsBody = secondBody.node?.physicsBody {
                        particlePhysicsBody.isDynamic = false
                        particlePhysicsBody.categoryBitMask = 0
                        particlePhysicsBody.contactTestBitMask = 0
                    }
                    parent?.removeAllActions()
                    parent?.run(SKAction.sequence([SKAction.scale(to: 0, duration: 0.1), SKAction.removeFromParent()]))

                    if type1 != type2 {
                        doGameOver()
                    } else {
                        doScore()
                    }
                }
            }
        }
        */
    }
}
