//
//  Int+Extensions.swift
//  Atom Attack
//
//  Created by Vladislav Jevremović on 12/30/17.
//  Copyright © 2015 Vladislav Jevremovic. All rights reserved.
//

import CoreGraphics

extension Int {

    static func random(_ upperLimit: Int) -> Int {
        return Int(arc4random_uniform(UInt32(upperLimit)))
    }
}
