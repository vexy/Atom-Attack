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
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}
