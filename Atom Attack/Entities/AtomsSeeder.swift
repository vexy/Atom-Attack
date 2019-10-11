//
//  AtomsSeeder.swift
//  Atom Attack
//
//  Created by Veljko Tekelerovic on 11.10.19.
//  Copyright © 2019 Vladislav Jevremovic. All rights reserved.
//

import SpriteKit

struct AtomsSeeder {
    private weak var containerScene: SKScene?   //avoiding strong referencing
    private let animationKey = "spawningAtoms"
    private var seedTimeout: TimeInterval = TimeInterval(2)
    
    /// Level scale for spawning logic
    public var currentLevel: Int {
        willSet { processLevelUpdate(newValue) }
    }
    
    init(scene: SKScene) {
        containerScene = scene
        currentLevel = 0
    }
    
    func spawnAtoms(repeat: Int) {
        
    }
    
    func startSpawningAtoms() {
        stopSpawningAtoms()
        
        let spawnAction = SKAction.run { self.spawnAtom() }
        let waitAction  = SKAction.wait(forDuration: seedTimeout)
        let continuosSpawning = SKAction.repeatForever(SKAction.sequence([spawnAction, waitAction]))

        containerScene?.run(continuosSpawning, withKey: animationKey)
    }
    
    func spawnAtom() {
        guard let theScene = containerScene else { return }
        
        let newAtom = Atom(color: getRandomAtomColor())
        newAtom.position(in: theScene)
    }
    
    func stopSpawningAtoms() {
        guard let liveScene = containerScene else { return }
        liveScene.removeAction(forKey: animationKey)
    }
    
    mutating private func processLevelUpdate(_ newLevel: Int) {
        //for now, just update seedTimeout as per original logic
        switch newLevel {
            case 1:
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
    
    /// Determines maximum number of Atoms allowed for given level
    private func maxAtomsForLevel() -> Int {
        var returnValue: Int = 0
        
        //TODO: ^^ put some fancy logic here ^^
        switch currentLevel {
            case 0...2:
                returnValue = 5
            case 2...4:
                returnValue = 9
            case 4... :
                returnValue = 13
            default:
                returnValue = 3
        }
        
        return returnValue
    }
    
    private func getRandomAtomColor() -> ColorTheme {
        let rnd = Int.random(in: 0..<2)
        return rnd == 0 ? ColorTheme.white : ColorTheme.black
    }

    private func getRandomSpeed() -> TimeInterval {
        //determine random boundaries based on the level
        var lowerBound: TimeInterval = 1.1
        
        //TODO: ^^ put some fancy logic here ^^
        switch currentLevel {
            case 0...2:
                lowerBound = 3.6
            case 2...4:
                lowerBound = 3.1
            case 4... :
                lowerBound = 2.8
            default:
                lowerBound = 3
        }
        
        let randomSpeed = Double.random(in: lowerBound..<6.5)
        return randomSpeed
    }

    private func getRandomDelay() -> TimeInterval {
        var lowerBound: TimeInterval = 2.55
        
        //TODO: ^^ put some fancy logic here ^^
        switch currentLevel {
            case 0...2:
                lowerBound = 3.14
            case 2...4:
                lowerBound = 2.62
            case 4... :
                lowerBound = 1.31
            default:
                lowerBound = 3.0
        }
        
        let randomDelay = Double.random(in: lowerBound..<6.5)
        return randomDelay
    }
}
