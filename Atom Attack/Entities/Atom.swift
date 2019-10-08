//
//  Atom.swift
//  Atom Attack
//
//  Created by Veljko Tekelerovic on 7.10.19.
//  Copyright © 2019 Vladislav Jevremovic. All rights reserved.
//

import SpriteKit

class Atom {
    private let atomShape: SKShapeNode
    private var atomColor: ColorTheme
    private var inAttackMode: Bool = false
    
    private var attackingSpeed: TimeInterval = 1.0 //TODO: experiment w/ this value
    public var movementSpeed: TimeInterval {
        willSet {
            assert(newValue > 0)
            attackingSpeed = newValue
        }
    }
    
    /// Flag indicating weather attack() method has been called
    public var isAttacking: Bool {
        return inAttackMode
    }
    
    init(color: ColorTheme = .white) {
        //variable initialization
        atomColor = color
        movementSpeed = attackingSpeed  //easier to experiment
        
        atomShape = SKShapeNode(circleOfRadius: 10)
        atomShape.name = "Atom"
        
        if atomColor == .black {
            atomShape.fillColor = SKColor.black
            atomShape.strokeColor = SKColor.black
        } else {
            atomShape.fillColor = SKColor.white
            atomShape.strokeColor = SKColor.white
        }
        
        atomShape.lineWidth = 0.1
        atomShape.position = CGPoint(x: 0, y: 0)
        atomShape.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        atomShape.physicsBody?.isDynamic = true
        atomShape.physicsBody?.categoryBitMask = rayCategory
        atomShape.physicsBody?.contactTestBitMask = coreCategory
    }
    
    func positionIn(scene: SKScene) {
        guard let sceneBounds = scene.view?.bounds else {
            fatalError("Unable to get scene bounds")
        }
        
        //adjust our Y and add us to root scene
        let screenWidth = sceneBounds.minX...sceneBounds.maxX
        let randomizedX = CGFloat.random(in: screenWidth)
        atomShape.position.x = randomizedX
        atomShape.position.y = sceneBounds.maxY
        scene.addChild(atomShape)
    }
    
    /// Attacks (moves) the Atom to a given point
    func attack(point: CGPoint) {
        let moveToFinalPosition = SKAction.move(to: point, duration: attackingSpeed)
        
        //update our flag first
        inAttackMode = true
        atomShape.run(moveToFinalPosition) { [weak self] in
            self?.inAttackMode = false
        }
    }
    
    func attack(point: CGPoint, after: TimeInterval) {
        let timeout = SKAction.wait(forDuration: after)
        atomShape.run(timeout) { [weak self] in
            self?.attack(point: point)
        }
    }
    
    func stopAttacking() {
        atomShape.removeAllActions()
    }
    
    func destroy() {
        atomShape.removeAllChildren()
        atomShape.removeAllActions()
        atomShape.removeFromParent()
    }
}
