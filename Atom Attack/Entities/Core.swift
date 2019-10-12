//
//  Core.swift
//  Atom Attack
//
//  Created by Veljko Tekelerovic on 6.10.19.
//  Copyright © 2019 Vladislav Jevremovic. All rights reserved.
//

import SpriteKit

struct Core {
    private let core: SKShapeNode
    private var coreColor: ColorTheme

    private let coreHalo: SKShapeNode = SKShapeNode(circleOfRadius: 25)
    private var haloScale: CGFloat = 1.0

    private let animationKey = "coreRotation"

    /// Returns the current position of the `Core` inside the parent's bounds
    public var position: CGPoint {
        return core.position
    }

    /// Creates new `Core` with given `ColorTheme`
    init(color: ColorTheme = .white) {
        coreColor = color

        let whiteFactor = CGFloat(coreColor == .white ? 1 : 0)

        core = SKShapeNode(circleOfRadius: 25)
        core.name = "Core"
        core.fillColor = SKColor(white: whiteFactor, alpha: 1.0)
        core.strokeColor = SKColor(white: whiteFactor, alpha: 1.0)
        core.lineWidth = 0.1
        core.zPosition = 2
        core.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        core.physicsBody?.isDynamic = false
        core.physicsBody?.categoryBitMask = PhysicsBitmask.CoreBitmask
        core.physicsBody?.contactTestBitMask = PhysicsBitmask.RayBitmask
        fillCoreWithParticles()

        setupHalo()
        core.addChild(coreHalo)
    }

    private func fillCoreWithParticles() {
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
            particle.strokeColor = SKColor(white: 185.0 / 255.0, alpha: 1.0)
            particle.lineWidth = 0.1
            particle.position = particlePosition
            particle.zPosition = 3
            core.addChild(particle)
        }
    }

    private func setupHalo() {
        coreHalo.fillColor = SKColor.lightGray
        coreHalo.strokeColor = SKColor.lightGray
        coreHalo.lineWidth = 0.25
        coreHalo.zPosition = 1
        coreHalo.alpha = 0.25
        coreHalo.physicsBody?.isDynamic = false
    }
}

// MARK: - Public methods
extension Core {
    /// Places the Core on the given `SKScene`. Actuall placement is fixed
    func place(in scene: SKScene) {
        guard let frame = scene.view?.frame else { fatalError("Unable to get Scene frame") }
        core.position = CGPoint(x: frame.midX, y: frame.midY * 0.4)

        //add as a child of the given scene
        scene.addChild(core)
    }

    /// Removes the core from the scene
    func removeFromScene() {
        core.removeAllActions()
        core.removeAllChildren()
        core.removeFromParent()
    }

    /// Starts spinning the Core
    func startSpinning() {
        let rotationAction = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 2.5))
        core.run(rotationAction, withKey: animationKey)
    }

    /// Stops spinning the Core
    func stopSpinning() {
        core.removeAction(forKey: animationKey)
    }

    /// Performs hit animation on Core
    mutating func receiveHit() {
        haloScale += 1
        animateHaloScaling()
    }

    /// Starts spinning the Core
    mutating func resetHalo() {
        haloScale = 1
        animateHaloScaling()
    }

    /// Defines the actual `SKAction` that scales the core.
    mutating private func animateHaloScaling() {
        let scaleAction = SKAction.scale(to: haloScale, duration: 0.2)
        coreHalo.run(scaleAction)
    }

    /// Toggles Core base color.
    mutating func toggleCoreColor() {
        //first, toggle current color
        if coreColor == .black {
            coreColor = .white
        } else {
            coreColor = .black
        }

        //change color of core and particles depending on the current color
        let newColor: UIColor = coreColor == .white ? .white : .black
        core.fillColor = newColor
        core.strokeColor = newColor
        core.children.forEach {
            ($0 as? SKShapeNode)?.fillColor = newColor
        }
    }
}
