//
//  CGFloat+Extensions.swift
//  Atom Attack
//
//  Created by Vladislav Jevremović on 12/30/17.
//  Copyright © 2015 Vladislav Jevremovic. All rights reserved.
//

import CoreGraphics

extension CGFloat {

    static func random() -> CGFloat {
        let seed: Float = Float(0xFFFFFFFF)                //explicit Float cast removes compiler warnings on precision issues (remove Float cast to see original warning)
        return CGFloat(Float(arc4random()) / seed)
    }

    /// Generates random `CGFloat` inside given boundaries
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}
