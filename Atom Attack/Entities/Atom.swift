//
//  Atom.swift
//  Atom Attack
//
//  Created by Veljko Tekelerovic on 7.10.19.
//  Copyright © 2019 Vladislav Jevremovic. All rights reserved.
//

import SpriteKit

/// Class encapsulating Atom entity
class Atom {
    private let atomShape: SKShapeNode
    private var atomColor: ColorTheme
    private var inMotion: Bool = false
    private let actionName = "attackingAction"

    private var attackingSpeed: TimeInterval = 5.0      //TODO: experiment w/ this value
    public var motionSpeed: TimeInterval {
        willSet {
            assert(newValue > 0)
            attackingSpeed = newValue
        }
    }

    /// Creates new `Atom` with given base color theme
    required init(color: ColorTheme = .white) {
        //variable initialization
        atomColor = color
        motionSpeed = attackingSpeed  //easier to experiment

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
        atomShape.physicsBody?.categoryBitMask = PhysicsBitmask.RayBitmask
        atomShape.physicsBody?.contactTestBitMask = PhysicsBitmask.CoreBitmask
    }

    /// Creates new `Atom` with default (white) base color theme
    convenience init() {
        self.init(color: .white)
    }

    /// Returns `true` if the atom is in motion (attacking), `false` otherwise
    public var isAttacking: Bool {
        return inMotion
    }
}

// MARK: - Public methods
extension Atom {
    /**
       Places the atom on the given `SKScene`.
     
       Positioning is fixed on Y axis, while randomized on X axis. Top-most part of the screen is taken as base Y.
       If the passed scene object isn't valid or had expired in the meantime, the function will `fatalError()` immediatelly.
       - parameters:
         - scene: Valid `SKScene` object.
     */
    func position(in scene: SKScene) {
        guard let sceneBounds = scene.view?.bounds else { fatalError("Unable to get scene bounds") }

        //adjust our X and Y and add us to root scene
        let screenWidth = sceneBounds.minX...sceneBounds.maxX
        let randomizedX = CGFloat.random(in: screenWidth)
        atomShape.position.x = randomizedX
        atomShape.position.y = sceneBounds.maxY
        scene.addChild(atomShape)
    }

    /// Starts moving the Atom to a given point
    func attack(point: CGPoint) {
        let attackAnimation = setupAttackAnimation(target: point)

        //update our flag
        inMotion = true
        atomShape.run(attackAnimation) { [weak self] in
            self?.inMotion = false
        }
    }

    /// Starts moving the Atom to a given point after specified delay
    func attack(point: CGPoint, after: TimeInterval) {
        let delay = SKAction.wait(forDuration: after)
        let attackAnimation = setupAttackAnimation(target: point)
        let deleyedAttackAnimation = SKAction.sequence([delay, attackAnimation])

        atomShape.run(deleyedAttackAnimation)
    }

    /// Stops the Atom immediatelly. Atom remains on its last poistion where it has beed stopped.
    func stopAttacking() {
        atomShape.removeAllActions()
    }

    /// Removes the Atom from the scene.
    func removeFromScene() {
        atomShape.removeAllChildren()
        atomShape.removeAllActions()
        atomShape.removeFromParent()
    }
}

// MARK: - Animation methods & utilities
extension Atom {
    private func setupAttackAnimation(target: CGPoint) -> SKAction {
        let attachRay = SKAction.run { self.attachRay() }
        let attackTarget = buildAttackAction(target: target)
        let removalAction = SKAction.run { self.removeFromScene() }
        let attackingSequence = SKAction.sequence([
            attachRay,
            attackTarget,
            removalAction
        ])

        return attackingSequence
    }

    /// Attaches atom ray to the current atom
    private func attachRay() {
        let rayNode = SKShapeNode(rect: CGRect(x: -10, y: 0, width: 20, height: 3_000))
        let whiteFactor: CGFloat = atomColor == .black ? 0.2 : 1.0

        rayNode.fillColor = SKColor(white: whiteFactor, alpha: 0.2)
        rayNode.strokeColor = SKColor.clear
        rayNode.lineWidth = 0.1
        rayNode.zPosition = 1

        //side effect of following the path motion is the rotation towards the target followed
        //as a result, we need to (re)rotate the ray by 180 degrees to make it look as desired (oriented outwards of the screen)
        let rotationAngle = SKAction.rotate(byAngle: .pi, duration: 0.01)
        rayNode.run(rotationAngle)

        atomShape.addChild(rayNode)
    }

    /// Creates `SKAction` that follows a path to a given target
    private func buildAttackAction(target: CGPoint) -> SKAction {
        let animationPath = CGMutablePath()     //UIBezierPath insted ?
        animationPath.move(to: atomShape.position)
        animationPath.addLine(to: target)
        animationPath.closeSubpath()

        return SKAction.follow(animationPath, asOffset: false, orientToPath: true, duration: attackingSpeed)
        //orienting to path (orientToPath = true) during follow() causes the atom ray to be (mis)rotated directly towards the Core
        //as the side effect, actuall ray has to be rotated properly during creation (see lines 143+)
    }
}
