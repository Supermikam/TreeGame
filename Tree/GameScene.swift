
// the tree can grow by it self, all node children of the scene

import UIKit
import SpriteKit


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
        let action = #selector(GameScene.cut(sender:))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:action)
        view.addGestureRecognizer(panGestureRecognizer)
        
        
        let x = self.frame.size.width / 2
        let y = self.frame.size.height * 0.1
        
        startTree(x1: x, y1: y, angle: 90, depth: 9)
        
//        drawTree()
        
        
    }
    
    
    func cut( sender: UIPanGestureRecognizer){
        switch sender.state{
        case .began :
            let point = SKSpriteNode(texture: nil, color:UIColor.red, size: CGSize(width: 3, height: 3))
            var position = sender.location(in: sender.view)
            position.y = self.frame.height - position.y
            point.position = position
            point.name = "point"
            self.gameBoard.addChild(point)
        case .changed:
            let point = self.gameBoard.childNode(withName: "point") as! SKSpriteNode
            var position = sender.location(in: sender.view)
            position.y = self.frame.height - position.y
            point.position = position
        case .cancelled, .ended:
            let point = self.gameBoard.childNode(withName: "point") as! SKSpriteNode
            point.removeFromParent()
        default: break
        }
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
