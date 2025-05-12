//
//  gameScene.swift
//
//  Created by Evan Booth and Justin Andre
//

import CoreMotion
import SpriteKit

//Collision categories represented as bit masks
// used for physics and object detection, behaves differently depending on value


enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case trophy = 4
    case vortex = 8
    case finish = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    var playerStartPosition: CGPoint?
    var lastTouchPosition: CGPoint?

    var motionManager: CMMotionManager! //handles tilts

    var isGameOver = false
    var scoreLabel: SKLabelNode!

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    override func didMove(to view: SKView) {
        //create background image
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)

        //create score label in bottom left
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        addChild(scoreLabel)

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        loadLevel()

        // start accelerometer input for motion based cntrls
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }

    //load level from .txt file level1, place tiles from chars of ASCII
    func loadLevel() {
        if let levelPath = Bundle.main.path(forResource: "level1", ofType: "txt") {
            if let levelString = try? String(contentsOfFile: levelPath) {
                let lines = levelString.components(separatedBy: "\n")

                let tileSize = 64
                let levelHeight = lines.count * tileSize
                let levelWidth = (lines.first?.count ?? 0) * tileSize

                // Calculate the offset to center the level
                let xOffset = (Int(size.width) - levelWidth) / 2
                let yOffset = (Int(size.height) - levelHeight) / 2
                
                
                for (row, line) in lines.reversed().enumerated() {
                    for (column, letter) in line.enumerated() {
                        let position = CGPoint(
                            x: (tileSize * column) + tileSize / 2 + xOffset,
                            y: (tileSize * row) + tileSize / 2 + yOffset
                        )
                        //match chars in level1.txt to objects in game
                        switch letter {
                        case "x":
                            let node = SKSpriteNode(imageNamed: "block")
                            node.position = position
                            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                            node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                            node.physicsBody?.isDynamic = false
                            addChild(node)

                        case "v":
                            let node = SKSpriteNode(imageNamed: "vortex")
                            node.name = "vortex"
                            node.position = position
                            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                            node.physicsBody?.isDynamic = false
                            node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
                            node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                            node.physicsBody?.collisionBitMask = 0
                            addChild(node)

                        case "s": //modify to t
                            let node = SKSpriteNode(imageNamed: "trophy")
                            node.name = "trophy"
                            node.position = position
                            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                            node.physicsBody?.isDynamic = false
                            node.physicsBody?.categoryBitMask = CollisionTypes.trophy.rawValue
                            node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                            node.physicsBody?.collisionBitMask = 0
                            addChild(node)

                        case "f": //finish line
                            let node = SKSpriteNode(imageNamed: "finish")
                            node.name = "finish"
                            node.position = position
                            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                            node.physicsBody?.isDynamic = false
                            node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
                            node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                            node.physicsBody?.collisionBitMask = 0
                            addChild(node)
                            
                        case "p": //spawn point
                            playerStartPosition = position

                        default:
                            break
                        }
                    }
                }
                //place player at start
                if let start = playerStartPosition {
                    createPlayer(at: start)
                } else {
                    fatalError("Player start position ('p') not found in level file.")
                }

            }
        }
    }

    //create player with proper SKPhysics collision logic
    func createPlayer(at position: CGPoint) {
        player = SKSpriteNode(imageNamed: "player")
        player.position = position //set starting position at p in txt file
        player.physicsBody = SKPhysicsBody(circleOfRadius: max(player.size.width, player.size.height) / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5 //simulate friction after collisions
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue //label object as player
        
        player.physicsBody?.contactTestBitMask = CollisionTypes.trophy.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue //define what the player node can contact
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player) //add it to screen
    }

    //touch controls
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            lastTouchPosition = location
        }
    }

    //for when player drags cursor
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            lastTouchPosition = location
        }
    }
    //stop applying gravity, touches ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }

    //called every single frame
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        
        #if targetEnvironment(simulator)
        //pull towards touch using gravity
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
            }
        #else
        //if using real device use accelerometer to read tilt inputs
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
            }
        #endif
    }

    // if player collides, find what, call playerCollided(with:) handle it
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == player {
            playerCollided(with: contact.bodyB.node!)
        } else if contact.bodyB.node == player {
            playerCollided(with: contact.bodyA.node!)
        }
    }

    //collision response, reset if vortex, update score, etc.
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            //vortex
            player.physicsBody?.isDynamic = false //freeze player
            isGameOver = true // pause
            score -= 1

            //pull towards center of vortex then delete it
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])

            //run vortex deletion animation and respawn
            player.run(sequence) { [unowned self] in
                player.removeFromParent() // remove old player
                if let start = self.playerStartPosition {
                    self.createPlayer(at: start)
                }
                self.isGameOver = false // unpause
            }

        } else if node.name == "trophy" {
            //collect point
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            // next level would go here
            //game is over, show EndScreen
            if let view = self.view {
                    let endScene = EndScene(size: view.bounds.size)
                    endScene.finalScore = score
                    endScene.scaleMode = .resizeFill
                    view.presentScene(endScene, transition: .crossFade(withDuration: 1.0))
                }
        }
    }
}

