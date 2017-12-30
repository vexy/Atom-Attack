//
//  GameScene.swift
//  Atom Attack
//
//  Created by Vladislav Jevremović on 11/28/15.
//  Copyright (c) 2015 Vladislav Jevremovic. All rights reserved.
//

import SpriteKit
import QuartzCore
import AudioToolbox

class GameScene: SKScene, SKPhysicsContactDelegate {

    var corehalo: SKShapeNode?
    var core: SKShapeNode?
    var ray: SKShapeNode?
    var particle: SKShapeNode?
    var score: Int = 0
    var labelScore: SKLabelNode?
    var labelLevel: SKLabelNode?
    var level: Int = 0
    var haloScale: CGFloat = 1.0
    var backgroundFlashNode: SKShapeNode?
    var gameOver = false
    var canReset = false
    var rays = SKNode()

    var actionCoreToggleColor: SKAction?

    let coreCategory: UInt32 = 1 << 0
    let rayCategory: UInt32 = 1 << 1

    override func didMove(to view: SKView) {
        /* Setup your scene here */

        self.backgroundColor = SKColor(white: 185.0/255.0, alpha: 1.0)

        self.addChild(rays)

        // gradient
        let topColor = CIColor(red:0.8, green:0.8, blue:0.8, alpha:1)
        let bottomColor = CIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        let backgroundTexture = SKTexture.textureWithVerticalGradient(size: self.size, topColor: topColor, bottomColor: bottomColor)
        let backgroundGradient = SKSpriteNode(texture: backgroundTexture)
        backgroundGradient.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        backgroundGradient.zPosition = -1
        self.addChild(backgroundGradient)

        backgroundFlashNode = SKShapeNode(rect: self.frame)
        if let backgroundFlashNode = backgroundFlashNode {
            backgroundFlashNode.fillColor = self.backgroundColor
            backgroundFlashNode.alpha = 0.0
            backgroundFlashNode.zPosition = 0
            self.addChild(backgroundFlashNode)
        }

        self.physicsWorld.gravity = CGVector.zero
        self.physicsWorld.contactDelegate = self

        labelScore = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
        if let labelScore = labelScore {
            labelScore.fontSize = 48
            labelScore.position = CGPoint(x: self.frame.width * 0.55, y: self.frame.height * 0.9)
            labelScore.zPosition = 1
            labelScore.alpha = 0.8
            labelScore.horizontalAlignmentMode = .right
            self.addChild(labelScore)
        }

        labelLevel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
        if let labelLevel = labelLevel {
            labelLevel.fontSize = 24
            labelLevel.position = CGPoint(x: self.frame.width * 0.551, y: self.frame.height * 0.925)
            labelLevel.zPosition = 1
            labelLevel.alpha = 0.8
            labelLevel.horizontalAlignmentMode = .left
            self.addChild(labelLevel)
        }

        corehalo = SKShapeNode(circleOfRadius: 25)
        if let corehalo = corehalo {
            corehalo.fillColor = SKColor.lightGray
            corehalo.strokeColor = SKColor.lightGray
            corehalo.lineWidth = 1.0
            corehalo.position = CGPoint(x: self.frame.midX, y: self.frame.midY * 0.4)
            corehalo.zPosition = 1
        }

        core = SKShapeNode(circleOfRadius: 25)
        if let core = core {
            core.fillColor = SKColor(white: 1.0, alpha: 1.0)
            core.strokeColor = SKColor(white: 1.0, alpha: 1.0)
            core.lineWidth = 0.1
            core.position = CGPoint(x: self.frame.midX, y: self.frame.midY * 0.4)
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

            for (_, particlePosition) in particlePositions.enumerated() {
                let particle = SKShapeNode(circleOfRadius: 10)
                particle.fillColor = core.fillColor
                particle.strokeColor = self.backgroundColor
                particle.lineWidth = 0.1
                particle.position = particlePosition
                core.addChild(particle)
            }

            self.addChild(core)
        }

        actionCoreToggleColor = SKAction.run({() -> Void in
            if let core = self.core {
                if let type = core.userData?["type"] as? Int {
                    if type > 0 {
                        core.fillColor = SKColor(white: 1.0, alpha: 1.0)
                        core.strokeColor = SKColor(white: 1.0, alpha: 1.0)
                        for (_, child) in core.children.enumerated() {
                            (child as? SKShapeNode)?.fillColor = SKColor(white: 1.0, alpha: 1.0)
                        }
                    } else {
                        core.fillColor = SKColor(white: 0.0, alpha: 1.0)
                        core.strokeColor = SKColor(white: 0.0, alpha: 1.0)
                        for (_, child) in core.children.enumerated() {
                            (child as? SKShapeNode)?.fillColor = SKColor(white: 0.0, alpha: 1.0)
                        }
                    }
                    core.userData?["type"] = 1 - type
                }
            }
        })

        self.resetScene()
    }

    func resetScene() {
        gameOver = false
        canReset = false

        score = 0
        level = 0

        labelScore?.text = "\(score)"
        labelLevel?.text = "\(level)"

        haloScale = 1.0
        if let corehalo = corehalo {
            corehalo.xScale = haloScale
            corehalo.yScale = haloScale
            corehalo.alpha = 1.0
            self.addChild(corehalo)
        }

        core?.alpha = 1.0
        core?.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 2.5)), withKey: "coreRotation")

        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run({ () -> Void in self.spawnRays() }), SKAction.wait(forDuration: 2.0)])), withKey: "spawnRays")
    }

    func spawnRays() {
        if gameOver {
            return
        }

        let alpha = CGFloat.random(min: -CGFloat.pi / 6, max: CGFloat.pi / 6)
        let offsetRadius: CGFloat = 500

        ray = SKShapeNode(rect: CGRect(x: -10, y: 0, width: 20, height: 5000))
        if let ray = ray {
            ray.userData = ["type": Int.random(2)]

            if let type = ray.userData?["type"] as? Int {
                if type > 0 {
                    ray.fillColor = SKColor(white: 0.2, alpha: 0.2)
                    ray.strokeColor = SKColor.clear
                } else  {
                    ray.fillColor = SKColor(white: 1.0, alpha: 0.2)
                    ray.strokeColor = SKColor.clear
                }
            }

            ray.lineWidth = 0.1
            ray.position = CGPoint(x: self.frame.midX + offsetRadius * -sin(alpha),
                                   y: self.frame.midY * 0.4 + offsetRadius * cos(alpha))
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

            ray.run(SKAction.sequence([SKAction.moveBy(x: 2000 * sin(alpha), y: -2000 * cos(alpha), duration: 5), SKAction.removeFromParent()]))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameOver {
            core?.run(actionCoreToggleColor!)
        } else {
            if canReset {
                self.resetScene()
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        let parent = secondBody.node?.parent

        if ((firstBody.categoryBitMask & coreCategory) == coreCategory) {
            if let type1 = self.core?.userData?["type"] as? Int {
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
                        gameOver = true

                        SKTAudio.shared().playSoundEffect("Explosion.mp3")
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

                        rays.removeAllChildren()

                        core?.removeAction(forKey: "coreRotation")

                        let oldColor = self.backgroundFlashNode!.fillColor

                        corehalo?.run(SKAction.sequence([SKAction.group([SKAction.fadeAlpha(to: 0.0, duration: 0.2), SKAction.scale(to: 0, duration: 0.2)]), SKAction.removeFromParent()]))

                        self.removeAction(forKey: "flash")
                        let wait = SKAction.wait(forDuration: 0.05)
                        let fadeBackgroundIn = SKAction.run({() in self.backgroundFlashNode!.alpha = 1.0 })
                        let fadeBackgroundOut = SKAction.run({() in self.backgroundFlashNode!.alpha = 0.0 })
                        let turnBackgroundRed = SKAction.run({() in self.backgroundFlashNode!.fillColor = UIColor.red })
                        let turnBackgroundWhite = SKAction.run({() in self.backgroundFlashNode!.fillColor = UIColor.white })
                        let turnBackgroundOriginal = SKAction.run({() in self.backgroundFlashNode!.fillColor = oldColor })
                        let sequenceOfActions = SKAction.sequence([turnBackgroundRed, wait, turnBackgroundWhite, wait, turnBackgroundOriginal])
                        let flashSequence = SKAction.sequence([fadeBackgroundIn, SKAction.repeat(sequenceOfActions, count: 4), fadeBackgroundOut,
                                                               SKAction.run({() in self.removeAllActions(); self.canReset = true })])
                        self.run(flashSequence, withKey: "flash")
                    } else {
                        SKTAudio.shared().playSoundEffect("Contact.mp3")

                        score += 1
                        labelScore?.text = "\(score)"

                        if score > 0 && score % 5 == 0 {
                            level += 1
                            labelLevel?.text = "\(level)"

                            var timeToSpawn = 2.5;
                            switch (level) {
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

                            self.removeAction(forKey: "spawnRays")
                            self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run({ () -> Void in self.spawnRays() }), SKAction.wait(forDuration: timeToSpawn)])), withKey: "spawnRays")

                            haloScale = 1.0
                        } else {
                            haloScale += 1.0
                        }

                        corehalo?.run(SKAction.scale(to: haloScale, duration: 0.2))
                    }
                }
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
