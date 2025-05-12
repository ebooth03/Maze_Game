
import SpriteKit

// Tap entry point for the game.
// Displays the title and a "Tap to Start" label.
// Tapping transitions to the main GameScene.

class MenuScreen: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = .blue

        //welcoming title and tap prompt
        let titleLabel = SKLabelNode(text: "Welcome to the Maze Game")
        titleLabel.fontName = "Helvetica"
        titleLabel.fontSize = 40
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
        addChild(titleLabel)

        let startLabel = SKLabelNode(text: "Tap to Start")
        startLabel.name = "start"
        startLabel.fontName = "Helvetica"
        startLabel.fontSize = 30
        startLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(startLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //detect if/when the user taps screen
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = atPoint(location) //recursively check until screen is tapped anywhere using atPoint()

        //transition to game once triggered
        if tappedNode.name == "start" {
            let gameScene = GameScene(size: self.size)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: SKTransition.flipVertical(withDuration: 1.0))
        }
    }
}


