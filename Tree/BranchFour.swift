//
//  BranchTwo.swift
//  Tree
//
//  Created by Ruohan Liu on 22/04/17.
//  Copyright © 2017 Ruohan Liu. All rights reserved.
//

import SpriteKit
import UIKit

class BranchFour: SKSpriteNode{
    let depth : Int
    let angle : Double
    let parentBranch : String
    
    init (length:CGFloat, depth:Int, angle:Double, color:UIColor, parentBranch: String, yPosition: CGFloat){
        self.depth = depth
        self.angle = angle
        self.parentBranch = parentBranch
        
        
        
        let size = CGSize(width: 2.0, height: length)
        
        super.init(texture:nil, color: color, size: size)
        
        self.anchorPoint = CGPoint(x:0.5,y:0.0)
        self.zRotation = CGFloat(angle.degrees_to_radians()-Double.pi/2)
        self.position = CGPoint(x:0,y:yPosition)
        self.zPosition = Layer.Tree
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

