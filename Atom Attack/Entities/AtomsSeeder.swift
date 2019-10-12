//
//  AtomsSeeder.swift
//  Atom Attack
//
//  Created by Veljko Tekelerovic on 11.10.19.
//  Copyright © 2019 Vladislav Jevremovic. All rights reserved.
//

import SpriteKit

final class AtomsSeeder {
    private weak var containerScene: SKScene?   //avoiding strong referencing
    private let animationKey = "spawningAtoms"
    private var seedTimeout: TimeInterval = TimeInterval(2)

    /// Level scale for spawning logic
    public var currentLevel: Int {
        willSet { processLevelUpdate(newValue) }
    }

    private var _spawnedAtoms: [Atom] = []
    public var spawnedAtoms: [Atom] {
        get { _spawnedAtoms }   //Swift 5 nerd !
    }
    //
    public var attackingAtoms: [Atom] {
        get { _spawnedAtoms.filter { $0.isAttacking } }
    }
    //
    public var nonAttackingAtoms: [Atom] {
        get { _spawnedAtoms.filter { !$0.isAttacking } }
    }

    init(scene: SKScene) {
        containerScene = scene
        currentLevel = 0
    }

    func startSpawningAtoms() {
        stopSpawningAtoms()

        let spawnAction = SKAction.run { self.spawnAtom() }
        let waitAction = SKAction.wait(forDuration: seedTimeout)
        let continuosSpawning = SKAction.repeatForever(SKAction.sequence([spawnAction, waitAction]))

        containerScene?.run(continuosSpawning, withKey: animationKey)
    }

    private func spawnAtom() {
        guard let theScene = containerScene else { return }

        let newAtom = Atom(color: getRandomAtomColor())
        newAtom.position(in: theScene)

        //update our container
        _spawnedAtoms.append(newAtom)
    }

    func stopSpawningAtoms() {
        guard let liveScene = containerScene else { return }
        liveScene.removeAction(forKey: animationKey)

        //update our container
        _spawnedAtoms.forEach { $0.destroy() }
        _spawnedAtoms.removeAll()
    }

    private func processLevelUpdate(_ newLevel: Int) {
        //for now, just update seedTimeout as per original logic
        switch newLevel {
            case 0..<1:
                seedTimeout = 2.0
            case 2:
                seedTimeout = 1.5
            case 3:
                seedTimeout = 1.0
            case 4:
                seedTimeout = 0.5
            case 5...:
                seedTimeout = 0.25
            default:
                seedTimeout = 0.25
        }
    }

    private func getRandomAtomColor() -> ColorTheme {
        let rnd = Int.random(in: 0..<2)
        return rnd == 0 ? ColorTheme.white : ColorTheme.black
    }
}
