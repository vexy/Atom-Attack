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
    private let actionKeyName = "seedAtoms"
    
//    public var currentLevel: Int
    
    init(scene: SKScene) {
        containerScene = scene
    }
    
    func spawnAtoms(repeat: Int) {
        
    }
    
    func startSpawningAtoms() {
        stopSpawningAtoms()
        
        let spawnAction = SKAction.run { self.spawnAtom() }
        let waitAction = SKAction.wait(forDuration: 2.5)
        
        let continuosSpawning = SKAction.repeatForever(SKAction.sequence([spawnAction, waitAction]))
        
        containerScene?.run(continuosSpawning, withKey: actionKeyName)
    }
    
    func stopSpawningAtoms() {
        guard let liveScene = containerScene else { return }
        liveScene.removeAction(forKey: actionKeyName)
    }
    
    func spawnAtom() {
        guard let theScene = containerScene else { return }
        
        let newAtom = Atom(color: getRandomAtomColor())
        newAtom.positionIn(scene: theScene)
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
