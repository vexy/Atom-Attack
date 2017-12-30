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

    private var coreHalo: SKShapeNode?
    private var core: SKShapeNode?
    private var ray: SKShapeNode?
    private var particle: SKShapeNode?
    private var score: Int = 0
    private var labelScore: SKLabelNode?
    private var labelLevel: SKLabelNode?
    private var level: Int = 0
    private var haloScale: CGFloat = 1.0
    private var backgroundFlashNode: SKShapeNode?
    private var gameOver: Bool = false
    private var canReset: Bool = false
    private var rays: SKNode = SKNode()

    private var actionCoreToggleColor: SKAction?

    private let coreCategory: UInt32 = 1 << 0
    private let rayCategory: UInt32 = 1 << 1

    // MARK: - Private Methods

    private func setupGradient() {
        let topColor = CIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        let bottomColor = CIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        let backgroundTexture = SKTexture.textureWithVerticalGradient(size: size,
                                                                      topColor: topColor,
                                                                      bottomColor: bottomColor)
        let backgroundGradient = SKSpriteNode(texture: backgroundTexture)
        backgroundGradient.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundGradient.zPosition = -1
        addChild(backgroundGradient)
    }

    private func setupBackgroundFlash() {
        backgroundFlashNode = SKShapeNode(rect: frame)
        if let backgroundFlashNode = backgroundFlashNode {
            backgroundFlashNode.fillColor = backgroundColor
            backgroundFlashNode.alpha = 0.0
            backgroundFlashNode.zPosition = 0
            addChild(backgroundFlashNode)
        }
    }

    private func setupLabelScore() {
        labelScore = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
        if let labelScore = labelScore {
            labelScore.fontSize = 48
            labelScore.position = CGPoint(x: frame.width * 0.55, y: frame.height * 0.9)
            labelScore.zPosition = 1
            labelScore.alpha = 0.8
            labelScore.horizontalAlignmentMode = .right
            addChild(labelScore)
        }
    }

    private func setupLabelLevel() {
        labelLevel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
        if let labelLevel = labelLevel {
            labelLevel.fontSize = 24
            labelLevel.position = CGPoint(x: frame.width * 0.551, y: frame.height * 0.925)
            labelLevel.zPosition = 1
            labelLevel.alpha = 0.8
            labelLevel.horizontalAlignmentMode = .left
            addChild(labelLevel)
        }
    }

    private func setupCoreHalo() {
        coreHalo = SKShapeNode(circleOfRadius: 25)
        if let corehalo = coreHalo {
            corehalo.fillColor = SKColor.lightGray
            corehalo.strokeColor = SKColor.lightGray
            corehalo.lineWidth = 1.0
            corehalo.position = CGPoint(x: frame.midX, y: frame.midY * 0.4)
            corehalo.zPosition = 1
        }
    }

    private func setupCore() {
        core = SKShapeNode(circleOfRadius: 25)
        if let core = core {
            core.fillColor = SKColor(white: 1.0, alpha: 1.0)
            core.strokeColor = SKColor(white: 1.0, alpha: 1.0)
            core.lineWidth = 0.1
            core.position = CGPoint(x: frame.midX, y: frame.midY * 0.4)
            core.zPosition = 3
            core.userData = ["type": 0]

            core.physicsBody = SKPhysicsBody(circleOfRadius: 25)
            if let corePhysicsBody = core.physicsBody {
                corePhysicsBody.isDynamic = false
                corePhysicsBody.categoryBitMask = coreCategory
                corePhysicsBody.contactTestBitMask = rayCategory
            }

            let particlePositions = [
                CGPoint(x: 0.0, y: 20.0),
                CGPoint(x: 17.3, y: 10.0),
                CGPoint(x: 17.3, y: -10.0),
                CGPoint(x: 0.0, y: 0.0),
                CGPoint(x: -17.3, y: -10.0),
                CGPoint(x: -17.3, y: 10.0),
                CGPoint(x: 0.0, y: -20.0)
            ]

            for particlePosition in particlePositions {
                let particle = SKShapeNode(circleOfRadius: 10)
                particle.fillColor = core.fillColor
                particle.strokeColor = backgroundColor
                particle.lineWidth = 0.1
                particle.position = particlePosition
                core.addChild(particle)
            }

            addChild(core)
        }
    }

    private func setupToggle() {
        actionCoreToggleColor = SKAction.run {() -> Void in
            if let core = self.core {
                if let type = core.userData?["type"] as? Int {
                    if type > 0 {
                        core.fillColor = SKColor(white: 1.0, alpha: 1.0)
                        core.strokeColor = SKColor(white: 1.0, alpha: 1.0)
                        for child in core.children {
                            (child as? SKShapeNode)?.fillColor = SKColor(white: 1.0, alpha: 1.0)
                        }
                    } else {
                        core.fillColor = SKColor(white: 0.0, alpha: 1.0)
                        core.strokeColor = SKColor(white: 0.0, alpha: 1.0)
                        for child in core.children {
                            (child as? SKShapeNode)?.fillColor = SKColor(white: 0.0, alpha: 1.0)
                        }
                    }
                    core.userData?["type"] = 1 - type
                }
            }
        }
    }

    private func resetScene() {
        gameOver = false
        canReset = false

        score = 0
        level = 0

        labelScore?.text = "\(score)"
        labelLevel?.text = "\(level)"

        haloScale = 1.0
        if let corehalo = coreHalo {
            corehalo.xScale = haloScale
            corehalo.yScale = haloScale
            corehalo.alpha = 1.0
            addChild(corehalo)
        }

        core?.alpha = 1.0
        core?.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 2.5)), withKey: "coreRotation")

        let spawnRaysAction = SKAction.run { self.spawnRays() }
        let waitAction = SKAction.wait(forDuration: 2.0)
        run(SKAction.repeatForever(SKAction.sequence([spawnRaysAction, waitAction])), withKey: "spawnRays")
    }

    private func spawnRays() {
        if gameOver {
            return
        }

        let alpha = CGFloat.random(min: -CGFloat.pi / 6, max: CGFloat.pi / 6)
        let offsetRadius: CGFloat = 500

        ray = SKShapeNode(rect: CGRect(x: -10, y: 0, width: 20, height: 5_000))
        if let ray = ray {
            ray.userData = ["type": Int.random(2)]

            if let type = ray.userData?["type"] as? Int {
                if type > 0 {
                    ray.fillColor = SKColor(white: 0.2, alpha: 0.2)
                    ray.strokeColor = SKColor.clear
                } else {
                    ray.fillColor = SKColor(white: 1.0, alpha: 0.2)
                    ray.strokeColor = SKColor.clear
                }
            }

            ray.lineWidth = 0.1
            ray.position = CGPoint(x: frame.midX + offsetRadius * -sin(alpha),
                                   y: frame.midY * 0.4 + offsetRadius * cos(alpha))
            ray.zPosition = 2

            particle = SKShapeNode(circleOfRadius: 10)
            if let particle = particle {
                if let type = ray.userData?["type"] as? Int {
                    if type > 0 {
                        particle.fillColor = SKColor.black
                        particle.strokeColor = SKColor.black
                    } else {
                        particle.fillColor = SKColor.white
                        particle.strokeColor = SKColor.white
                    }
                }

                particle.lineWidth = 0.1
                particle.position = CGPoint(x: 0, y: 0)

                particle.physicsBody = SKPhysicsBody(circleOfRadius: 10)
                if let particlePhysicsBody = particle.physicsBody {
                    particlePhysicsBody.isDynamic = true
                    particlePhysicsBody.categoryBitMask = rayCategory
                    particlePhysicsBody.contactTestBitMask = coreCategory
                }

                ray.addChild(particle)
            }
            ray.zRotation = alpha

            rays.addChild(ray)

            ray.run(SKAction.sequence([SKAction.moveBy(x: 2_000 * sin(alpha), y: -2_000 * cos(alpha), duration: 5),
                                       SKAction.removeFromParent()]))
        }
    }

    private func doGameOver() {
        gameOver = true

        SKTAudio.shared.playSoundEffect("Explosion.mp3")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        rays.removeAllChildren()

        core?.removeAction(forKey: "coreRotation")

        let oldColor = backgroundFlashNode?.fillColor ?? .clear

        let fadeAction = SKAction.fadeAlpha(to: 0.0, duration: 0.2)
        let scaleAction = SKAction.scale(to: 0, duration: 0.2)
        coreHalo?.run(SKAction.sequence([SKAction.group([fadeAction, scaleAction]), SKAction.removeFromParent()]))

        removeAction(forKey: "flash")
        let wait = SKAction.wait(forDuration: 0.05)
        let fadeBackgroundIn = SKAction.run { self.backgroundFlashNode?.alpha = 1.0 }
        let fadeBackgroundOut = SKAction.run { self.backgroundFlashNode?.alpha = 0.0 }
        let turnBackgroundRed = SKAction.run { self.backgroundFlashNode?.fillColor = UIColor.red }
        let turnBackgroundWhite = SKAction.run { self.backgroundFlashNode?.fillColor = UIColor.white }
        let turnBackgroundOriginal = SKAction.run { self.backgroundFlashNode?.fillColor = oldColor }
        let actions = [turnBackgroundRed, wait, turnBackgroundWhite, wait, turnBackgroundOriginal]
        let sequenceOfActions = SKAction.sequence(actions)
        let repeatAction = SKAction.repeat(sequenceOfActions, count: 4)
        let resetAction = SKAction.run { self.removeAllActions(); self.canReset = true }
        let flashSequence = SKAction.sequence([fadeBackgroundIn, repeatAction, fadeBackgroundOut, resetAction])
        run(flashSequence, withKey: "flash")
    }

    private func doScore() {
        SKTAudio.shared.playSoundEffect("Contact.mp3")

        score += 1
        labelScore?.text = "\(score)"

        if score > 0 && score % 5 == 0 {
            level += 1
            labelLevel?.text = "\(level)"

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

            haloScale = 1.0
        } else {
            haloScale += 1.0
        }

        coreHalo?.run(SKAction.scale(to: haloScale, duration: 0.2))
    }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor(white: 185.0 / 255.0, alpha: 1.0)

        addChild(rays)
        setupGradient()
        setupBackgroundFlash()

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        setupLabelScore()
        setupLabelLevel()
        setupCoreHalo()
        setupCore()
        setupToggle()

        resetScene()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameOver {
            if let action = actionCoreToggleColor {
                core?.run(action)
            }
        } else {
            if canReset {
                resetScene()
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        let parent = secondBody.node?.parent

        if firstBody.categoryBitMask & coreCategory == coreCategory {
            if let type1 = core?.userData?["type"] as? Int {
                if let type2 = parent?.userData?["type"] as? Int {
                    // disable collisions while shaking
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
    }
}
