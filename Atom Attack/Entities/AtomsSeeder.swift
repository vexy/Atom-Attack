//
//  AtomsSeeder.swift
//  Atom Attack
//
//  Created by Veljko Tekelerovic on 11.10.19.
//  Copyright © 2019 Vladislav Jevremovic. All rights reserved.
//

import SpriteKit

/// Class used to encapsulate atoms seeding logic
final class AtomsSeeder {
    private weak var containerScene: SKScene?   //avoiding strong referencing and protecting from scene expiry
    private let animationKey = "spawningAtoms"
    private var seedTimeout: TimeInterval = TimeInterval(2)

    // current game level
    public var currentLevel: Int {
        willSet { updateSeedTimeout(newValue) }
    }

    private var _spawnedAtoms: [Atom] = []
    public var spawnedAtoms: [Atom] {
        get { _spawnedAtoms }   //Swift 5 nerd !
    }

    /// Returns the array of `Atom`s currently in attacking motion
    public var attackingAtoms: [Atom] {
        get { _spawnedAtoms.filter { $0.isAttacking } }
    }
    /// Returns the array of `Atom`s that are still (not moving/attacking)
    public var nonAttackingAtoms: [Atom] {
        get { _spawnedAtoms.filter { !$0.isAttacking } }
    }

    init(scene: SKScene) {
        containerScene = scene
        currentLevel = 0
    }
}

// MARK: - Public methods
extension AtomsSeeder {
    /// Starts creating Atoms on the screen
    func startSpawning() {
        // cleanup
        stopSpawning()

        let continuosSpawning = spawningSequence()
        containerScene?.run(continuosSpawning, withKey: animationKey)
    }

    /// Stops creating Atoms on the screen. All previously spawned atoms will be removed from the sceen automatically.
    func stopSpawning() {
        guard let liveScene = containerScene else { return }
        liveScene.removeAction(forKey: animationKey)

        //update our container
        _spawnedAtoms.forEach { $0.removeFromScene() }
        _spawnedAtoms.removeAll()
    }
}

// MARK: - Private methods (animations & utilities)
extension AtomsSeeder {
    private func spawningSequence() -> SKAction {
        let spawnAction = SKAction.run { self.spawnAtom() }
        let waitAction = SKAction.wait(forDuration: seedTimeout)
        let finalSequence = SKAction.repeatForever(SKAction.sequence([spawnAction, waitAction]))

        return finalSequence
    }

    /// Spawns and places new atom on the scene
    private func spawnAtom() {
        guard let theScene = containerScene else { return }

        let newAtom = Atom(color: getRandomColor())
        newAtom.position(in: theScene)

        //update our container
        _spawnedAtoms.append(newAtom)
    }

    /// Updates `seedTimeout` variable according to the current level
    private func updateSeedTimeout(_ newLevel: Int) {
        //for now, just update seedTimeout as per original logic
        switch newLevel {
            case 0...1:
                seedTimeout = 2.0
            case 2:
                seedTimeout = 1.5
            case 3:
                seedTimeout = 1.0
            case 4:
                seedTimeout = 0.5
            default:
                seedTimeout = 0.25
        }
    }

    /// Returns random `ColorTheme`
    private func getRandomColor() -> ColorTheme {
        let rnd = Int.random(in: 0..<2)
        return rnd == 0 ? ColorTheme.white : ColorTheme.black
    }
}
