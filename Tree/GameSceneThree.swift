//branch catches touch event and delegate to scene to cut it 
//branch add physics body only when it is cut
//but behave strangely without knowing why
import UIKit
import SpriteKit



class GameSceneThree : SKScene, BranchTouchDelegate{
    //MARK: Type Alias
    typealias TreeData = [(position:[CGPoint], angle: Double, depth: Int)]
    
    // MARK: Display property
    
    let blue = UIColor(red: 0.0, green: 0.7373, blue: 1.0, alpha: 1.0)
    let BKGround = UIColor(colorLiteralRed: 0.4, green: 0.5, blue: 0.6, alpha: 1.0)
    
    // MARK: Node
    let gameBoard = SKNode()
    var treeData = TreeData()
    let treeDepth : Int = 9
    var treeLengthBaseFactor = CGFloat()
    // MARK: API
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.speed = 1.0

        //Set the Back Ground Color
        self.backgroundColor = BKGround
        self.addChild(gameBoard)
        //let action = #selector(GameScene.cut(sender:))
        //let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:action)
        //view.addGestureRecognizer(panGestureRecognizer)
        
        self.treeLengthBaseFactor = self.frame.width/60
        let length = CGFloat(self.treeDepth) * self.treeLengthBaseFactor
        
        startTree(length:length, angle: 90, depth: 9, parentName:"root")
        
    }
    
    
    
    func startTree(length: CGFloat, angle: Double, depth:Int, parentName:String, branchOrder: Int = 1){
        
        
        generateBranchNode(length: length, depth: depth, angle: angle, parentName:parentName, branchOrder: branchOrder)
        
        
        
    }
    
    func generateNewBranch(length:CGFloat, angle: Double, depth:Int, parentName:String){
        if depth  == 0 {
            return
        }
        
        startTree(length:length, angle: 70, depth: depth, parentName: parentName, branchOrder: 1)
        startTree(length:length, angle: 110, depth: depth, parentName: parentName, branchOrder: 2)
    }
    
    func generateBranchNode(length:CGFloat, depth:Int, angle:Double, parentName:String, branchOrder:Int){
        let branch = BranchThree(length: length, depth: depth, angle: angle, color: blue, parentBranch:parentName)
        branch.branchTouchDelegate = self
        
        let scaleAction = SKAction.scaleY(to: 1.0, duration: 2.0)
        branch.yScale = 0.01
        if (parentName == "root"){
            branch.name = "0"
            branch.position = CGPoint(x: self.frame.width/2, y: 30.0)
        }else{
            let parentNumber = Int(parentName)
            let childNumber = parentNumber! * 2 + branchOrder
            branch.name = String(childNumber)
        }
        branch.run(scaleAction)
        {
            () -> Void in
            let newLength = self.treeLengthBaseFactor * CGFloat(depth-1)
            self.generateNewBranch(length:newLength, angle: angle, depth: depth-1, parentName: branch.name!)
        };
        if (parentName == "root"){
            
            gameBoard.addChild(branch)
        }else{
            let parentNode = gameBoard.childNode(withName: ".//\(parentName)") as! SKSpriteNode
            parentNode.addChild(branch)
        }
        
    }
    
    func handleCut(sender: BranchThree, point: CGPoint) {
        cutTheBranchFromPoint(point, branch: sender)
    }
    
    
    func cutTheBranchFromPoint(_ point: CGPoint, branch: BranchThree){
            if branch.hasActions(){
                branch.removeAllActions()
            }else{
                let children = branch.children
                for childNode in children{
                    if childNode.hasActions(){
                        childNode.removeAllActions()
                    }
                }
            }
            
            //add a new branch node ad the remain half of the branch
            let touchedAt = point
            let parentNode = branch.parent as! BranchThree
            let cutNode = BranchThree(length: touchedAt.y, depth: branch.depth, angle: branch.angle, color: blue, parentBranch: parentNode.name!)
            cutNode.position = CGPoint(x:0.0, y: parentNode.size.height)
            cutNode.yScale = branch.yScale
            cutNode.name = branch.name! + "cut"
            parentNode.addChild(cutNode)
            
            //chenge the size of the other half 
            //add phisicsBody and drop
            
            
            branch.yScale = (branch.size.height-touchedAt.y)/branch.size.height
            branch.position = CGPoint(x:0.0, y: touchedAt.y)
            branch.physicsBody = SKPhysicsBody(rectangleOf: branch.size)
            branch.physicsBody?.categoryBitMask = UInt32(1)
            branch.physicsBody?.isDynamic = true
            
            let fadeAway = SKAction.fadeOut(withDuration: 0.25)
            let removeNode = SKAction.removeFromParent()
            let sequence = SKAction.sequence([fadeAway, removeNode])
            branch.isUserInteractionEnabled = false
            branch.run(sequence)
            let children = branch.children
            for childNode in children{
                let theNode = childNode as! BranchThree
                theNode.isUserInteractionEnabled = false
                theNode.run(sequence)
            }
        }
    
    
    
//    func cut( sender: UIPanGestureRecognizer){
//        switch sender.state{
//        case .began :
//            let point = SKSpriteNode(texture: nil, color:UIColor.red, size: CGSize(width: 3, height: 3))
//            var position = sender.location(in: sender.view)
//            position.y = self.frame.height - position.y
//            point.position = position
//            point.name = "point"
//            self.gameBoard.addChild(point)
//        case .changed:
//            let point = self.gameBoard.childNode(withName: "point") as! SKSpriteNode
//            var position = sender.location(in: sender.view)
//            position.y = self.frame.height - position.y
//            point.position = position
//        case .cancelled, .ended:
//            let point = self.gameBoard.childNode(withName: "point") as! SKSpriteNode
//            point.removeFromParent()
//        default: break
//        }
//    }
    
}

