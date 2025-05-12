//  EndScreen.swift
//
//  Created by Evan Booth and Justin Andre 
//
//End Screen for whenever player reaches finish line
// Shows Final Score and then restarts at tap of button

import SpriteKit

class EndScene: SKScene {
    var finalScore: Int = 0

    override func didMove(to view: SKView) {
        backgroundColor = .black

        let message = SKLabelNode(text: "Game Over")
        message.fontName = "Helvetica"
        message.fontSize = 40
        message.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
        addChild(message)

        //show final score
        let scoreLabel = SKLabelNode(text: "Your score: \(finalScore)")
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 30
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(scoreLabel)
        
        //prompt
        let retryLabel = SKLabelNode(text: "Tap to Restart")
        retryLabel.name = "retry"
        retryLabel.fontName = "Helvetica"
        retryLabel.fontSize = 24
        retryLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 80)
        addChild(retryLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //once tapped, go back to start, MenuScreen.swift
        if let view = view {
            let menuScreen = MenuScreen(size: view.bounds.size)
            menuScreen.scaleMode = .resizeFill
            view.presentScene(menuScreen, transition: .flipVertical(withDuration: 0.5))
        }
    }
}
