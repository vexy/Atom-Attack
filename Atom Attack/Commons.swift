//
//  Commons.swift
//  Atom Attack
//
//  Created by Veljko Tekelerovic on 7.10.19.
//  Copyright © 2019 Vladislav Jevremovic. All rights reserved.
//

import SpriteKit

// GLOBAL PHYSIC CATEGORISATION
struct PhysicsBitmask {
    static let CoreBitmask: UInt32 = 1 << 0
    static let RayBitmask: UInt32 = 1 << 1
}

/// Enum describing base color scheme of an object
internal enum ColorTheme {
    case white
    case black
}
