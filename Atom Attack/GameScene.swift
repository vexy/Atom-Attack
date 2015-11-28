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
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.backgroundColor = SKColor(white: 185.0/255.0, alpha: 1.0)
        
        self.addChild(rays)
        
        // gradient
        let topColor = CIColor(red:0.8, green:0.8, blue:0.8, alpha:1)
        let bottomColor = CIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        let backgroundTexture = SKTexture.textureWithVerticalGradient(size: self.size, topColor: topColor, bottomColor: bottomColor)
        let backgroundGradient = SKSpriteNode(texture: backgroundTexture)
        backgroundGradient.position = CGPointMake(self.size.width / 2, self.size.height / 2)
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
            labelScore.horizontalAlignmentMode = .Right
            self.addChild(labelScore)
        }
        
        labelLevel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
        if let labelLevel = labelLevel {
            labelLevel.fontSize = 24
            labelLevel.position = CGPoint(x: self.frame.width * 0.551, y: self.frame.height * 0.925)
            labelLevel.zPosition = 1
            labelLevel.alpha = 0.8
            labelLevel.horizontalAlignmentMode = .Left
            self.addChild(labelLevel)
        }
        
        corehalo = SKShapeNode(circleOfRadius: 25)
        if let corehalo = corehalo {
            corehalo.fillColor = SKColor.lightGrayColor()
            corehalo.strokeColor = SKColor.lightGrayColor()
            corehalo.lineWidth = 1.0
            corehalo.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) * 0.4)
            corehalo.zPosition = 1
        }
        
        core = SKShapeNode(circleOfRadius: 25)
        if let core = core {
            core.fillColor = SKColor(white: 1.0, alpha: 1.0)
            core.strokeColor = SKColor(white: 1.0, alpha: 1.0)
            core.lineWidth = 0.1
            core.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) * 0.4)
            core.zPosition = 3
            core.userData = ["type": 0]
            
            core.physicsBody = SKPhysicsBody(circleOfRadius: 25)
            if let corePhysicsBody = core.physicsBody {
                corePhysicsBody.dynamic = false
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
            
            for (_, particlePosition) in particlePositions.enumerate() {
                let particle = SKShapeNode(circleOfRadius: 10)
                particle.fillColor = core.fillColor
                particle.strokeColor = self.backgroundColor
                particle.lineWidth = 0.1
                particle.position = particlePosition
                core.addChild(particle)
            }
            
            self.addChild(core)
        }
        
        actionCoreToggleColor = SKAction.runBlock({() -> Void in
            if let core = self.core {
                if let type = core.userData?["type"] as? Int {
                    if type > 0 {
                        core.fillColor = SKColor(white: 1.0, alpha: 1.0)
                        core.strokeColor = SKColor(white: 1.0, alpha: 1.0)
                        for (_, child) in core.children.enumerate() {
                            (child as? SKShapeNode)?.fillColor = SKColor(white: 1.0, alpha: 1.0)
                        }
                    } else {
                        core.fillColor = SKColor(white: 0.0, alpha: 1.0)
                        core.strokeColor = SKColor(white: 0.0, alpha: 1.0)
                        for (_, child) in core.children.enumerate() {
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
        // SKTAudio.sharedInstance().playBackgroundMusic("Music.mp3")
        
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
        core?.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI), duration: 2.5)), withKey: "coreRotation")
        
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock({ () -> Void in self.spawnRays() }), SKAction.waitForDuration(2.0)])), withKey: "spawnRays")
    }
    
    func spawnRays() {
        if gameOver {
            return
        }
        
        let alpha = CGFloat.random(min: CGFloat(-M_PI / 6), max: CGFloat(M_PI / 6))
        let offsetRadius: CGFloat = 500
        
        ray = SKShapeNode(rect: CGRectMake(-10, 0, 20, 5000))
        if let ray = ray {
            ray.userData = ["type": Int.random(2)]
            
            if let type = ray.userData?["type"] as? Int {
                if type > 0 {
                    ray.fillColor = SKColor(white: 0.2, alpha: 0.2)
                    ray.strokeColor = SKColor.clearColor()
                } else  {
                    ray.fillColor = SKColor(white: 1.0, alpha: 0.2)
                    ray.strokeColor = SKColor.clearColor()
                }
            }
            
            ray.lineWidth = 0.1
            ray.position = CGPoint(x: CGRectGetMidX(self.frame) + offsetRadius * -sin(alpha),
                y: CGRectGetMidY(self.frame) * 0.4 + offsetRadius * cos(alpha))
            ray.zPosition = 2
            
            particle = SKShapeNode(circleOfRadius: 10)
            if let particle = particle {
                if let type = ray.userData?["type"] as? Int {
                    if type > 0 {
                        particle.fillColor = SKColor.blackColor()
                        particle.strokeColor = SKColor.blackColor()
                    } else {
                        particle.fillColor = SKColor.whiteColor()
                        particle.strokeColor = SKColor.whiteColor()
                    }
                }
                
                particle.lineWidth = 0.1
                particle.position = CGPoint(x: 0, y: 0)
                
                particle.physicsBody = SKPhysicsBody(circleOfRadius: 10)
                if let particlePhysicsBody = particle.physicsBody {
                    particlePhysicsBody.dynamic = true
                    particlePhysicsBody.categoryBitMask = rayCategory
                    particlePhysicsBody.contactTestBitMask = coreCategory
                }
                
                ray.addChild(particle)
            }
            ray.zRotation = alpha
            
            rays.addChild(ray)
            
            ray.runAction(SKAction.sequence([SKAction.moveByX(2000 * sin(alpha), y: -2000 * cos(alpha), duration: 5), SKAction.removeFromParent()]))
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameOver {
            core?.runAction(actionCoreToggleColor!)
        } else {
            if canReset {
                self.resetScene()
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
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
                        particlePhysicsBody.dynamic = false
                        particlePhysicsBody.categoryBitMask = 0
                        particlePhysicsBody.contactTestBitMask = 0
                    }
                    parent?.removeAllActions()
                    parent?.runAction(SKAction.sequence([SKAction.scaleTo(0, duration: 0.1), SKAction.removeFromParent()]))
                    
                    if type1 != type2 {
                        gameOver = true
                        
                        SKTAudio.sharedInstance().pauseBackgroundMusic()
                        SKTAudio.sharedInstance().playSoundEffect("Explosion.mp3")
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
                        rays.removeAllChildren()
                        
                        core?.removeActionForKey("coreRotation")
                        
                        let oldColor = self.backgroundFlashNode!.fillColor
                        
                        corehalo?.runAction(SKAction.sequence([SKAction.group([SKAction.fadeAlphaTo(0.0, duration: 0.2), SKAction.scaleTo(0, duration: 0.2)]), SKAction.removeFromParent()]))
                        
                        self.removeActionForKey("flash")
                        let wait = SKAction.waitForDuration(0.05)
                        let fadeBackgroundIn = SKAction.runBlock({() in self.backgroundFlashNode!.alpha = 1.0 })
                        let fadeBackgroundOut = SKAction.runBlock({() in self.backgroundFlashNode!.alpha = 0.0 })
                        let turnBackgroundRed = SKAction.runBlock({() in self.backgroundFlashNode!.fillColor = UIColor.redColor() })
                        let turnBackgroundWhite = SKAction.runBlock({() in self.backgroundFlashNode!.fillColor = UIColor.whiteColor() })
                        let turnBackgroundOriginal = SKAction.runBlock({() in self.backgroundFlashNode!.fillColor = oldColor })
                        let sequenceOfActions = SKAction.sequence([turnBackgroundRed, wait, turnBackgroundWhite, wait, turnBackgroundOriginal])
                        let flashSequence = SKAction.sequence([fadeBackgroundIn, SKAction.repeatAction(sequenceOfActions, count: 4), fadeBackgroundOut,
                            SKAction.runBlock({() in self.removeAllActions(); self.canReset = true })])
                        self.runAction(flashSequence, withKey: "flash")
                    } else {
                        SKTAudio.sharedInstance().playSoundEffect("Contact.mp3")
                        
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
                            
                            self.removeActionForKey("spawnRays")
                            self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock({ () -> Void in self.spawnRays() }), SKAction.waitForDuration(timeToSpawn)])), withKey: "spawnRays")
                            
                            haloScale = 1.0
                        } else {
                            haloScale += 1.0
                        }
                        
                        corehalo?.runAction(SKAction.scaleTo(haloScale, duration: 0.2))
                    }
                }
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}