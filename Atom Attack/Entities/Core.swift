//
//  Core.swift
//  Atom Attack
//
//  Created by Veljko Tekelerovic on 6.10.19.
//  Copyright © 2019 Vladislav Jevremovic. All rights reserved.
//

import SpriteKit

struct Core {
    private var haloScale: CGFloat = 1.0
    private let backgroundColor = SKColor(white: 185.0 / 255.0, alpha: 1.0)
    
    private lazy var coreHalo: SKShapeNode = {
        let node = SKShapeNode(circleOfRadius: 25)
        node.fillColor = SKColor.lightGray
        node.strokeColor = SKColor.lightGray
        node.lineWidth = 0.25
        node.zPosition = 1
        node.alpha = 0.25
        node.physicsBody?.isDynamic = false
        
        return node
    }()
    
    private let coreShape: SKShapeNode
    private var coreColor: ColorTheme
    
    public var currentPosition: CGPoint {
        return coreShape.position
    }
    
    
    init(color: ColorTheme = .white) {
        coreColor = color
        let whiteFactor = CGFloat(coreColor == .white ? 1 : 0)
        
        coreShape = SKShapeNode(circleOfRadius: 25)
        coreShape.name = "Core"
        coreShape.fillColor = SKColor(white: whiteFactor, alpha: 1.0)
        coreShape.strokeColor = SKColor(white: whiteFactor, alpha: 1.0)
        coreShape.lineWidth = 0.1
        coreShape.zPosition = 2
        coreShape.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        coreShape.physicsBody?.isDynamic = false
        coreShape.physicsBody?.categoryBitMask = coreCategory
        coreShape.physicsBody?.contactTestBitMask = rayCategory
        
        addCoreParticles()
        coreShape.addChild(coreHalo)
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
            particle.fillColor = coreShape.fillColor
            particle.strokeColor = backgroundColor
            particle.lineWidth = 0.1
            particle.position = particlePosition
            particle.zPosition = 3
            coreShape.addChild(particle)
        }
    }
}

// MARK:- Public methods
extension Core {
    func place(in scene: SKScene) {
        guard let frame = scene.view?.frame else { fatalError("Unable to get Scene frame") }
        coreShape.position = CGPoint(x: frame.midX, y: frame.midY * 0.4)
        
        //add as a child of the given scene
        scene.addChild(coreShape)
    }
    
    func removeFromScene() {
        coreShape.removeAllActions()
        coreShape.removeAllChildren()
        coreShape.removeFromParent()
    }
    
    func startSpinning() {
        let rotationAction = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 2.5))
        coreShape.run(rotationAction, withKey: "coreRotation")
    }
    
    func stopSpinning() {
        coreShape.removeAction(forKey: "coreRotation")
    }
    
    mutating func receiveHit() {
        haloScale += 1
        performHaloScale()
    }
    
    mutating func resetHalo() {
        haloScale = 1
        performHaloScale()
    }
    
    mutating private func performHaloScale() {
        let scaleAction = SKAction.scale(to: haloScale, duration: 0.2)
        coreHalo.run(scaleAction)
    }
    
    mutating func toggleColorScheme() {
        //first, toggle current color
        if coreColor == .black {
            coreColor = .white
        } else {
            coreColor = .black
        }
        
        //change color of core and particles depending on the current color
        let newColor: UIColor = coreColor == .white ? .white : .black
        coreShape.fillColor     = newColor
        coreShape.strokeColor   = newColor
        coreShape.children.forEach {
            ($0 as? SKShapeNode)?.fillColor = newColor
        }
    }
}
