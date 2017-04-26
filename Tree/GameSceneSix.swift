import Foundation

import UIKit
import SpriteKit

class GameSceneSix : SKScene{
    //MARK: Display property
    let blue = UIColor(red:0.17, green:0.15, blue:0.15, alpha:1.0)
    let BKGround = UIColor(colorLiteralRed: 0.4, green: 0.5, blue: 0.6, alpha: 1.0)
    
    // MARK: Node
    var particles: SKEmitterNode?
    var gameBoard : BranchFour!
    
    let treeDepth : Int = 9
    var treeLengthBaseFactor = CGFloat()
    var treeSizeFactor : CGFloat = 1.0
    var growingBranchNumber: Int = 0
    
    // MARK: API
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.speed = 1.0
        
        //set up background
        setUpScenery()
        gameBoard = BranchFour(length: 1.0, depth: 10, angle: 90, color: blue, parentBranch: "Scene", yPosition: 0.0)
        gameBoard.position = CGPoint(x: self.frame.width * 0.32, y: self.frame.height * 0.162)
        gameBoard.name = "root"
        self.addChild(gameBoard)
        self.treeLengthBaseFactor = self.frame.width/60
        let length = CGFloat(sqrt(Double(self.treeDepth))) * self.treeLengthBaseFactor
        
        startTree(length:length, angle: 90, depth: 9, parentName:"root")
        
    }
    
 
    
    func startTree(length: CGFloat, angle: Double, depth:Int, parentName:String, branchOrder: Int = 1){
        generateBranchNode(length: length, depth: depth, angle: angle, parentName:parentName, branchOrder: branchOrder)
    }
    
    func generateNewBranch(length:CGFloat, angle: Double, depth:Int, parentName:String){
        if depth  == 0 {
            return
        }
        
        let leftAngle: UInt32 = arc4random_uniform(20)
        let rightAngle: UInt32 = arc4random_uniform(20)
        let leftAngleNoise: Int = Int(leftAngle) - 10
        let rightAngleNoise: Int = Int(rightAngle) - 10
        
        let leftLengthNoise: CGFloat = CGFloat(Double(100 + leftAngleNoise * 3)/100)
        let rightLengthNoise: CGFloat = CGFloat(Double(100 + rightAngleNoise * 3)/100)
        
        if depth <= 5{
            let branchGrowthRate:UInt32 = arc4random_uniform(100)
            if branchGrowthRate>=70{
                let direction: UInt32 = arc4random_uniform(100)
                if direction >= 50{
                    startTree(length:length * rightLengthNoise * treeSizeFactor, angle: Double(70 + rightAngleNoise), depth: depth, parentName: parentName, branchOrder: 1)
                }else{
                    startTree(length: length * leftLengthNoise * treeSizeFactor, angle: Double(110 + leftAngleNoise), depth: depth, parentName: parentName, branchOrder: 2)
                }
            }else{
                startTree(length:length * rightLengthNoise * treeSizeFactor, angle: Double(70 + rightAngleNoise), depth: depth, parentName: parentName, branchOrder: 1)
                startTree(length:length * leftLengthNoise * treeSizeFactor, angle: Double(110 + leftAngleNoise), depth: depth, parentName: parentName, branchOrder: 2)
            }
        }else{
            startTree(length:length * rightLengthNoise * treeSizeFactor, angle: Double(70 + rightAngleNoise), depth: depth, parentName: parentName, branchOrder: 1)
            startTree(length:length * leftLengthNoise * treeSizeFactor, angle: Double(110 + leftAngleNoise), depth: depth, parentName: parentName, branchOrder: 2)
        }
    }
    
    func generateBranchNode(length:CGFloat, depth:Int, angle:Double, parentName:String, branchOrder:Int){
        
        var parentNode: BranchFour
        if parentName == "root"{
            parentNode = gameBoard
        }else{
            parentNode = gameBoard.childNode(withName: ".//\(parentName)") as! BranchFour
        }
        
        let branch = BranchFour(length: length, depth: depth, angle: angle, color: blue, parentBranch:parentName, yPosition: parentNode.size.height )
        
        //monitor how many branch is still growing
        growingBranchNumber += 1
        let Noise: UInt32 = arc4random_uniform(100)
        let durationNoise = Double(Noise)/100.0
        
        let scaleAction = SKAction.scaleY(to: 1.0, duration: (2.0 - durationNoise))
        branch.yScale = 0.01
        if (parentName == "root"){
            branch.name = "0"
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
            self.growingBranchNumber -= 1
            
            let newLength = self.treeLengthBaseFactor * CGFloat(sqrt(Double(depth-1)))
            
            self.generateNewBranch(length:newLength, angle: angle, depth: depth-1, parentName: branch.name!)
        };
        if (parentName == "root"){
            
            gameBoard.addChild(branch)
        }else{
            
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
            var allDecendents = [SKNode]()
            allDecendents = getAllDecendants(node: branch)
            
            for childNode in allDecendents{
                if childNode.yScale < 1.0 {
                    growingBranchNumber -= 1
                }
                
                if childNode.hasActions(){
                    childNode.removeAllActions()
                }
            }
            
            //add a new branch node at the remain half of the branch
            var touchedAt = branch.convert(point, from: self.scene!)
            if touchedAt.y < 0 {
                touchedAt.y = -touchedAt.y
            }
            let parentNode = branch.parent as! BranchFour
            let cutNode = BranchFour(length: touchedAt.y, depth: branch.depth, angle: branch.angle, color: blue, parentBranch: parentNode.name!, yPosition: parentNode.size.height)
            
            cutNode.physicsBody = SKPhysicsBody(rectangleOf: cutNode.size, center: CGPoint(x:cutNode.size.width/2, y:cutNode.size.height/2))
            cutNode.physicsBody?.isDynamic = false
            
            cutNode.physicsBody?.categoryBitMask = UInt32(1)
            cutNode.name = name + "cut"
            parentNode.addChild(cutNode)
            
            
            //chenge the size of the other half and drop
            branch.yScale = (branch.size.height-touchedAt.y)/branch.size.height
            branch.position = CGPoint(x:0.0, y: touchedAt.y)
            branch.physicsBody?.isDynamic = true
            branch.physicsBody?.allowsRotation = true
            
            let fadeAway = SKAction.fadeOut(withDuration: 0.25)
            let removeNode = SKAction.removeFromParent()
            let sequence = SKAction.sequence([fadeAway, removeNode])
            branch.run(sequence){
                () -> Void in
                if (self.hasLiveTipBranch() || self.growingBranchNumber > 0) && !branch.name!.contains("cut") {
                    
                    //let decendants = self.getAllDecendants(node: branch)
                    //let scaleFactor = CGFloat(Double(decendants.count)/250.0 + 1.0)
                    
                    let scaleFactor = CGFloat(1.0 + sqrt(Double(branch.depth))/(Double(self.treeDepth - branch.depth)*Double(self.treeDepth - branch.depth) * 10.0))
                    
                    self.treeSizeFactor *= scaleFactor
                    
                    
                    let resize = SKAction.scale(to: self.treeSizeFactor, duration: 0.5)
                    //let trunc = self.gameBoard.childNode(withName: "0")
                    //trunc?.run(resize)
                    self.gameBoard.run(resize)
                }else{
                    
                }
            }
            for childNode in allDecendents{
                let theNode = childNode as! BranchFour
                theNode.run(sequence)
            }
        }
    }
    
    func hasLiveTipBranch() -> Bool{
        
        var liveTipBranchCount : Int = 0
        let allBranches = getAllDecendants(node: gameBoard)
        for eachBranch in allBranches{
            if let theBranch = eachBranch as? BranchFour{
                if theBranch.depth == 1{
                    liveTipBranchCount += 1
                }
            }
        }
        
        if liveTipBranchCount > 0 {
            return true
        }else{
            return false
        }
    }
    
    func getAllDecendants(node: SKNode) -> [SKNode]{
        var decendants = [SKNode]()
        let directChildren = node.children
        if directChildren.count > 0{
            decendants += directChildren
            for eachNode in directChildren{
                let grandChildren = getAllDecendants(node: eachNode)
                if grandChildren.count > 0{
                    decendants += grandChildren
                }
            }
            return decendants
        }else {return decendants}
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
    
    
    func setUpScenery() {
        let background = SKSpriteNode(imageNamed: ImageName.Background)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = Layer.Background
        background.size = CGSize(width: size.width, height: size.height)
        self.addChild(background)
        
        let ground = SKSpriteNode(imageNamed: ImageName.Ground)
        ground.anchorPoint = CGPoint(x: 0, y: 0)
        ground.position = CGPoint(x: 0, y: 0)
        ground.zPosition = Layer.Ground
        ground.size = CGSize(width: size.width, height: size.height)
        self.addChild(ground)
    }
}
