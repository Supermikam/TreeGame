//
//  Extentions.swift
//  Tree
//
//  Created by Ruohan Liu on 22/04/17.
//  Copyright © 2017 Ruohan Liu. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    func degrees_to_radians() -> CGFloat {
        return CGFloat(Double.pi) * self / 180.0
    }
}

extension CGPoint{
    static func - (left: CGPoint, right: CGPoint) -> CGFloat{
        return  sqrt((left.x - right.x)*(left.x-right.x)+(left.y-right.y)*(left.y-right.y))
    }
}

extension Double {
    func degrees_to_radians() -> Double {
        return Double.pi * self / 180.0
    }
}
