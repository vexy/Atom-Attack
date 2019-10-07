//
//  Protocols.swift
//  Atom Attack
//
//  Created by Veljko Tekelerovic on 7.10.19.
//  Copyright © 2019 Vladislav Jevremovic. All rights reserved.
//

import Foundation
import SpriteKit

protocol GameObject {
    func spawn() -> SKNode
    func attack(object: SKNode)
    
    func receivedHit()
}
