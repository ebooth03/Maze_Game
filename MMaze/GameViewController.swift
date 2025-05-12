
//
//  gameViewController.swift
//
//  Created by Evan Booth, Justin Andre 
//  View controller that loads and presents initial SpriteKit scene,

import UIKit
import SpriteKit

// UIVIewController points to this first
class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("GameViewController loaded")

        //try to check if the view is for SpriteKit, if so create MenuScreen
        if let skView = self.view as? SKView {
            let scene = MenuScreen(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            skView.presentScene(scene) // create and go to MenuScreen

            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        } else {
            print("View didnt load correctly") //error statement
        }
    }

    //rotate when screen orientation changes on real device
    override var shouldAutorotate: Bool {
        return true
    }

    //supported interations sent to iOS
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    //hide status bar which has the battery, time, etc.
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

