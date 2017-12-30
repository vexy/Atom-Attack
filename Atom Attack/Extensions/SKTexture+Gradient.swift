//
//  SKTexture+Gradient.swift
//  Atom Attack
//
//  Created by Vladislav Jevremovic on 12/31/14.
//  Copyright © 2014 Vladislav Jevremovic. All rights reserved.
//

import SpriteKit

extension SKTexture {

    class func textureWithVerticalGradient(size: CGSize,
                                           topColor: CIColor,
                                           bottomColor: CIColor) -> SKTexture? {
        let coreImageContext = CIContext(options: nil)
        if let gradientFilter = CIFilter(name: "CILinearGradient") {
            gradientFilter.setDefaults()

            let startVector = CIVector(x: size.width / 2, y: 0)
            gradientFilter.setValue(startVector, forKey: "inputPoint0")
            let endVector = CIVector(x: size.width / 2, y: size.height)
            gradientFilter.setValue(endVector, forKey: "inputPoint1")
            gradientFilter.setValue(bottomColor, forKey: "inputColor0")
            gradientFilter.setValue(topColor, forKey: "inputColor1")

            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            if
                let outputImage = gradientFilter.outputImage,
                let cgimg = coreImageContext.createCGImage(outputImage, from: rect) {
                return SKTexture(image: UIImage(cgImage: cgimg))
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
