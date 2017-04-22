//
//  Branch.swift
//  Tree
//
//  Created by Ruohan Liu on 17/04/17.
//  Copyright © 2017 Ruohan Liu. All rights reserved.
//

import SpriteKit
import UIKit

class Branch: SKSpriteNode{
    let origin :CGPoint
    let end : CGPoint
    let depth : Int
    let angle : Double

    
    init (origin:CGPoint, end: CGPoint, depth:Int, angle:Double, color:UIColor){
        self.origin = origin
        self.end = end
        self.depth = depth
        self.angle = angle
        
        let size = CGSize(width: 2.0, height: (end-origin))
    
        super.init(texture:nil, color: color, size: size)
        
        self.anchorPoint = CGPoint(x:0.5,y:0.0)
        self.zRotation = CGFloat(angle.degrees_to_radians()-Double.pi/2)
        self.position = origin
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
