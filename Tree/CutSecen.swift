//
//  CutSecen.swift
//  Tree
//
//  Created by Ruohan Liu on 22/04/17.
//  Copyright © 2017 Ruohan Liu. All rights reserved.
//

import UIKit
import SpriteKit



class CutScene : SKScene{
    
    var aNode : SKSpriteNode!
    var bNode : SKSpriteNode!
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.lightGray
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.speed = 1.0
        
        addNode()
    }
    
    func addNode(){
        aNode = SKSpriteNode(texture: nil, color: UIColor.darkGray, size: CGSize(width: 20.0, height: 100.0))
        aNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        let center = CGPoint(x: aNode.size.width/2, y:aNode.size.height/2)
        aNode.physicsBody = SKPhysicsBody(rectangleOf: aNode.size, center: center )
        aNode.physicsBody?.categoryBitMask = UInt32(1)
        aNode.physicsBody?.isDynamic = false

        aNode.position = CGPoint(x:self.frame.width/2, y: 80.0)
        
        aNode.name = "a"
        
        self.scene?.addChild(aNode)
        
        bNode = SKSpriteNode(texture: nil, color: UIColor.blue, size: CGSize(width: 20.0, height: 100.0))
        bNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        let centerB = CGPoint(x: bNode.size.width/2, y:bNode.size.height/2)
        bNode.physicsBody = SKPhysicsBody(rectangleOf: bNode.size , center: centerB)
        bNode.physicsBody?.categoryBitMask = UInt32(1)
        bNode.physicsBody?.isDynamic = false
        bNode.position = CGPoint(x:0.0, y: aNode.size.height)
        
        bNode.name = "b"
        aNode.addChild(bNode)
    
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let startPoint = touch.location(in: self)
            let endPoint = touch.previousLocation(in: self)
            
            // check if vine cut
            scene?.physicsWorld.enumerateBodies(alongRayStart: startPoint, end: endPoint,
                                                using: { (body, point, normal, stop) in
                                                    self.checkIfVineCutWithBody(body, at: point)
            })
        
        }
    }
    
    
    func checkIfVineCutWithBody(_ body: SKPhysicsBody, at point:CGPoint) {
        let node = body.node!
        
        // if it has a name it must be a vine node
        if let name = node.name {
            
            let touchedAt = node.convert(point, from: self.scene!)
            
            let cutNode = SKSpriteNode(texture: nil, color: UIColor.cyan, size: CGSize(width: 20.0, height: touchedAt.y))
            cutNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            let centerC = CGPoint(x: cutNode.size.width/2, y:cutNode.size.height/2)
            cutNode.physicsBody = SKPhysicsBody(rectangleOf: bNode.size , center: centerC)
            cutNode.physicsBody?.categoryBitMask = UInt32(1)
            cutNode.physicsBody?.isDynamic = false
            let pNode = node.parent as! SKSpriteNode
            cutNode.position = CGPoint(x:0.0, y: pNode.size.height)
            cutNode.name = name + "cut"
            pNode.addChild(cutNode)

            node.yScale = (100.0-touchedAt.y)/100.0
            node.position = CGPoint(x:0.0, y: touchedAt.y)
            node.physicsBody?.isDynamic = true
            
        }
    }


}

