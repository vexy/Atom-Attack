//
//  Atom.swift
//  Atom Attack
//
//  Created by Veljko Tekelerovic on 7.10.19.
//  Copyright © 2019 Vladislav Jevremovic. All rights reserved.
//

import SpriteKit

struct Atom {
    private let atomShape: SKShapeNode
    private var atomColor: ColorTheme
    
    init(color: ColorTheme = .white) {
        atomColor = color
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
    
    func attack(point: CGPoint) {
        let moveToFinalPosition = SKAction.move(to: point, duration: 5)
        atomShape.run(moveToFinalPosition)
        // alternative :
        // atomShape.run(SKAction.sequence([moveToFinalPosition, .removeFromParent()]))
    }
    
    func attack(point: CGPoint, after: TimeInterval) {
        let timeout = SKAction.wait(forDuration: after)
        atomShape.run(timeout, completion: { self.attack(point: point) })
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
