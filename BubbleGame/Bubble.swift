//
//  Bubble.swift
//  BubbleGame
//
//  Created by Justin Heo on 11/6/15.
//  Copyright © 2015 Justin Heo. All rights reserved.
//

import UIKit
import SpriteKit

class Bubble: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: "bubble")

        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        
        self.name = "bubble"

        physicsBody = SKPhysicsBody(circleOfRadius: self.frame.size.width / 2)
        physicsBody?.dynamic = true
        physicsBody?.allowsRotation = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
