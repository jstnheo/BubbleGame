//
//  ViewController.swift
//  BubbleGame
//
//  Created by Justin Heo on 11/6/15.
//  Copyright © 2015 Justin Heo. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    @IBOutlet weak var bubbleGame: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 83.0/255, green: 118/255, blue: 185/255, alpha: 1).CGColor,
            UIColor(red: 0/255, green: 144/255, blue: 191/255, alpha: 1).CGColor]
        view.layer.insertSublayer(gradientLayer, atIndex: 0)

        let scene = BubblesScene(size: bubbleGame.frame.size, bubbleCount: 15, start: .Top, isPoppable: true)
        let skView = bubbleGame as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}


