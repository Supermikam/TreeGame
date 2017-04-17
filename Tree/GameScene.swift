

//
//  ClassicGameScene.swift
//  Slow
//
//  Created by Ruohan Liu on 20/03/17.
//  Copyright © 2017 Ruohan Liu. All rights reserved.
//

import UIKit
import SpriteKit

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

class GameScene : SKScene{
    //MARK: Type Alias
    typealias TreeData = [(position:[CGPoint], angle: Double, depth: Int)]
    
    // MARK: Display property

    let blue = UIColor(red: 0.0, green: 0.7373, blue: 1.0, alpha: 1.0)
    let BKGround = UIColor(colorLiteralRed: 0.4, green: 0.5, blue: 0.6, alpha: 1.0)
    
    // MARK: Node
    let gameBoard = SKNode()
    var treeData = TreeData()
    
    
    // MARK: API
    override func didMove(to view: SKView) {
        
        
        //Set the Back Ground Color
        self.backgroundColor = BKGround
        self.addChild(gameBoard)
        
        let x = self.frame.size.width / 2
        let y = self.frame.size.height * 0.1
        
        startTree(x1: x, y1: y, angle: 90, depth: 9)
        
//        drawTree()
        
        
    }
    
    func startTree(x1: CGFloat, y1: CGFloat, angle: Double, depth:Int){
        
        let ang = angle.degrees_to_radians()
        let x2:CGFloat = x1 + ( cos(CGFloat(ang)) as CGFloat) * CGFloat(depth) * (self.frame.width / 60)
        let y2:CGFloat = y1 + ( sin(CGFloat(ang)) as CGFloat) * CGFloat(depth) * (self.frame.width / 60)

        let origin = CGPoint(x:x1,y:y1)
        let end = CGPoint(x:x2,y:y2)
        
        generateBranchNode(origin: origin, end: end, depth: depth, angle: angle)
        

       
    }
    
    func generateNewBranch(x1: CGFloat, y1: CGFloat, angle: Double, depth:Int){
        if depth  == 0 {
            return
        }
        
        startTree(x1: x1, y1: y1, angle: angle-20, depth: depth)
        startTree(x1: x1, y1: y1, angle: angle+20, depth: depth)
    }
    
    func generateBranchNode(origin:CGPoint, end: CGPoint, depth:Int, angle:Double){
        let branch = Branch(origin: origin, end: end, depth: depth, angle: angle, color: blue)
        
        let scaleAction = SKAction.scaleY(to: 1.0, duration: 2.0)
        branch.yScale = 0.01
        branch.run(scaleAction)
        {
            () -> Void in
            self.generateNewBranch(x1: end.x, y1: end.y, angle: angle, depth: depth-1)
        };
        gameBoard.addChild(branch)
    }
  
  
//    func generateTree(x1: CGFloat, y1: CGFloat, angle: Double, depth:Int) {
//        
//        if depth == 0 {
//            return
//        }
//        let ang = angle.degrees_to_radians()
//        let x2:CGFloat = x1 + ( cos(CGFloat(ang)) as CGFloat) * CGFloat(depth) * (self.frame.width / 60)
//        let y2:CGFloat = y1 + ( sin(CGFloat(ang)) as CGFloat) * CGFloat(depth) * (self.frame.width / 60)
//        
//        let origin = CGPoint(x:x1,y:y1)
//        let end = CGPoint(x:x2,y:y2)
//        treeData.append((position:[origin,end],angle:angle, depth:depth))
//        
//        generateTree(x1: x2, y1: y2, angle: angle - 20, depth: depth - 1)
//        generateTree(x1: x2, y1: y2, angle: angle + 20, depth: depth - 1)
//    }
//    
//    func drawTree(){
//        for var line in treeData{
//            let treeLine = Branch(origin: line.position[0], end: line.position[1], depth: line.depth, angle: line.angle, color: blue)
//            gameBoard.addChild(treeLine)
//        }
//    }
}
