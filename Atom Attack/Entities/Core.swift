//
//  Core.swift
//  Atom Attack
//
//  Created by Veljko Tekelerovic on 6.10.19.
//  Copyright © 2019 Vladislav Jevremovic. All rights reserved.
//

import SpriteKit

enum ColorTheme {
    case white
    case black
}

struct Core {
    private let coreCategory: UInt32 = 1 << 0
    private let rayCategory: UInt32  = 1 << 1
    
    private var haloScale: CGFloat = 1.0
    
    private lazy var rotationAction: SKAction = {
        let coreRotation = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 2.5))
        return coreRotation
    }()
    
    private lazy var coreHalo: SKShapeNode = {
        let node = SKShapeNode(circleOfRadius: 25)
        node.fillColor = SKColor.lightGray
        node.strokeColor = SKColor.lightGray
        node.lineWidth = 1.0
        node.zPosition = 1
        
        return node
    }()
    
    private let core: SKShapeNode = SKShapeNode(circleOfRadius: 25)
    
    private func setupCore(in frame: CGRect) {
        core.fillColor = SKColor(white: 1.0, alpha: 1.0)
        core.strokeColor = SKColor(white: 1.0, alpha: 1.0)
        core.lineWidth = 0.1
        core.position = CGPoint(x: frame.midX, y: frame.midY * 0.4)
        core.zPosition = 3
        core.userData = ["type": 0]
        core.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        core.physicsBody?.isDynamic = false
        core.physicsBody?.categoryBitMask = coreCategory
        core.physicsBody?.contactTestBitMask = rayCategory
        
        addCoreParticles()
    }
    
    private func addCoreParticles() {
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
    }
    
    private func positionIn(frame: CGRect) {
        core.position = CGPoint(x: frame.midX, y: frame.midY * 0.4)
    }
    
    func receiveHit() {
        coreHalo.run(SKAction.sequence([SKAction.group([fadeAction, scaleAction]), SKAction.removeFromParent()]))
    }
    
    func startSpinning() {
        
        core.run(coreRotation, withKey: "coreRotation")
    }
    
    func stopSpinning() {
        
    }
    
    /// Creates new particle `SKShapeNode` object for the given type parameter
    private func createNewParticle(ofType type: Int) -> SKShapeNode {
        let newParticle = SKShapeNode(circleOfRadius: 10)
        
        if type > 0 {
            newParticle.fillColor = SKColor.black
            newParticle.strokeColor = SKColor.black
        } else {
            newParticle.fillColor = SKColor.white
            newParticle.strokeColor = SKColor.white
        }
        
        newParticle.lineWidth = 0.1
        newParticle.position = CGPoint(x: 0, y: 0)
        newParticle.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        newParticle.physicsBody?.isDynamic = true
        newParticle.physicsBody?.categoryBitMask = rayCategory
        newParticle.physicsBody?.contactTestBitMask = coreCategory
        
        return newParticle
    }
}
