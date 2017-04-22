//physics body attached to branch after it is fully grown 
//cut functions properly 
// change gameboard to a Branch node, root branch can be cut now.
//particle emitter used to track cut path
//particle to be adjusted later

import UIKit
import SpriteKit



class GameSceneFour : SKScene{
    //MARK: Type Alias
    typealias TreeData = [(position:[CGPoint], angle: Double, depth: Int)]
    
    // MARK: Display property
    
    let blue = UIColor(red: 0.0, green: 0.7373, blue: 1.0, alpha: 1.0)
    let BKGround = UIColor(colorLiteralRed: 0.4, green: 0.5, blue: 0.6, alpha: 1.0)
    
    // MARK: Node
    var particles: SKEmitterNode?
    var gameBoard : BranchFour!
    var treeData = TreeData()
    let treeDepth : Int = 9
    var treeLengthBaseFactor = CGFloat()
    // MARK: API
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.speed = 1.0
        
        //Set the Back Ground Color
        self.backgroundColor = BKGround
        gameBoard = BranchFour(length: 1.0, depth: 10, angle: 90, color: blue, parentBranch: "Scene")
        gameBoard.position = CGPoint(x: self.frame.width/2, y: 30.0)
        gameBoard.name = "Fixed Point"
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
        let branch = BranchFour(length: length, depth: depth, angle: angle, color: blue, parentBranch:parentName)
        
        let scaleAction = SKAction.scaleY(to: 1.0, duration: 2.0)
        branch.yScale = 0.01
        if (parentName == "root"){
            branch.name = "0"
            branch.position = CGPoint(x:0.0,y:1.0)
        }else{
            let parentNumber = Int(parentName)
            let childNumber = parentNumber! * 2 + branchOrder
            branch.name = String(childNumber)
        }
        branch.run(scaleAction)
        {
            () -> Void in
            branch.physicsBody = SKPhysicsBody(rectangleOf: branch.size, center: CGPoint(x:branch.size.width/2, y: branch.size.height/2))
            branch.physicsBody?.categoryBitMask = UInt32(1)
            branch.physicsBody?.isDynamic = false
            
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {
            let startPoint = touch.location(in: self)
            let endPoint = touch.previousLocation(in: self)
            
            // check and cut the branch
            scene?.physicsWorld.enumerateBodies(alongRayStart: startPoint, end: endPoint,
                                                using: { (body, point, normal, stop) in
                                                    self.cutTheBranchFromPoint(point, body: body)
            })
            
            // produce some nice particles
            showMoveParticles(touchPosition: startPoint)
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        particles?.removeFromParent()
        particles = nil
    }
    
    
    
    func cutTheBranchFromPoint(_ point: CGPoint, body: SKPhysicsBody){
        let node = body.node!
        if let name = node.name {

            let branch = node as! BranchFour
            
            //stop end brach from growing
            let children = branch.children
            for childNode in children{
                if childNode.hasActions(){
                    childNode.removeAllActions()
                }
            }
            
            //add a new branch node at the remain half of the branch
            let touchedAt = branch.convert(point, from: self.scene!)
            let parentNode = branch.parent as! BranchFour
            let cutNode = BranchFour(length: touchedAt.y, depth: branch.depth, angle: branch.angle, color: blue, parentBranch: parentNode.name!)
            cutNode.position = CGPoint(x:0.0, y: parentNode.size.height)
            cutNode.physicsBody = SKPhysicsBody(rectangleOf: cutNode.size, center: CGPoint(x:cutNode.size.width/2, y:cutNode.size.height/2))
            cutNode.physicsBody?.isDynamic = false
            cutNode.physicsBody?.categoryBitMask = UInt32(1)
            cutNode.name = name + "cut"
            parentNode.addChild(cutNode)
            
            
            //chenge the size of the other half and drop
            branch.yScale = (branch.size.height-touchedAt.y)/branch.size.height
            branch.position = CGPoint(x:0.0, y: touchedAt.y)
            branch.physicsBody?.isDynamic = true
            
            let fadeAway = SKAction.fadeOut(withDuration: 0.25)
            let removeNode = SKAction.removeFromParent()
            let sequence = SKAction.sequence([fadeAway, removeNode])
            branch.run(sequence)
            for childNode in children{
                let theNode = childNode as! BranchFour
                theNode.isUserInteractionEnabled = false
                theNode.run(sequence)
            }
        }
    }
    
    
    func showMoveParticles(touchPosition: CGPoint) {
        if particles == nil {
            particles = SKEmitterNode(fileNamed: "Particle.sks")
            particles!.zPosition = 1
            particles!.targetNode = self
            addChild(particles!)
        }
        particles!.position = touchPosition
    }
    

    
}

