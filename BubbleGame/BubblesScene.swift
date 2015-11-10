//
//  BubblesScene.swift
//  BubbleGame
//
//  Created by Justin Heo on 11/6/15.
//  Copyright © 2015 Justin Heo. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion

class BubblesScene : SKScene {
    private var startBubblesFromTop = false
    private let bubbleName = "bubble"
    private var count = 100
    private let padding: CGFloat = 200
    private var poppable = true
    private let motionManager = CMMotionManager()
    private var acceleration: CGFloat = 0

    enum StartPosition {
        case Top
        case Bottom
    }

    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.clearColor()
        view.allowsTransparency = true

        runAction(SKAction.repeatAction(SKAction.sequence([
            SKAction.runBlock({
                self.createBubble()
            }),
            SKAction.waitForDuration(0.5)
            ]), count: count))

        motionManager.startAccelerometerUpdates()
        motionManager.accelerometerUpdateInterval = 0.3

        guard let currentQueue = NSOperationQueue.currentQueue() else {
            print("No current queue")
            return
        }

        motionManager.startAccelerometerUpdatesToQueue(currentQueue) { data, _ in
            if let acceleration = data?.acceleration {
                self.acceleration = CGFloat(acceleration.x * 0.75) + (self.acceleration * 0.25)
            }
        }
    }

    override func didSimulatePhysics() {
        enumerateChildNodesWithName(bubbleName) { bubble, _ in
            guard let dy = bubble.physicsBody?.velocity.dy else {
                print("NO DY")
                return
            }

            bubble.physicsBody?.velocity = CGVectorMake(self.acceleration * 400, dy)
        }
    }

    init(size: CGSize, bubbleCount: Int, start: StartPosition, isPoppable: Bool) {
        count = bubbleCount
        poppable = isPoppable
        switch start {
        case .Top:
            startBubblesFromTop = true
        case .Bottom:
            startBubblesFromTop = false
        }
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }

    private func createBubble() {
        let scale = random(min: 0.25, max: 1)

        let bubble = Bubble()
        bubble.size = CGSizeMake(bubble.size.width * scale, bubble.size.height * scale)
        bubble.physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)

        let startX = frame.size.width * random(min: 0, max: 1)
        let startY = startBubblesFromTop ? size.height + padding : 0

        print(size.height)

        bubble.position = CGPoint(x: startX, y: startY)
        addChild(bubble)

        bubble.runAction(
            SKAction.followPath(createRandomPath(bubble.position), asOffset: true, orientToPath: false,
                duration: NSTimeInterval(random(min: 4, max: 8)))
        )
    }

    override func update(currentTime: NSTimeInterval) {
        enumerateChildNodesWithName(bubbleName) { bubble, _ in
            print(bubble.position)
//            if bubble.position.y > self.size.height + self.padding || bubble.position.y < -self.padding {
//                bubble.removeFromParent()
//            }
        }
    }

    private func createRandomPath(startPosition: CGPoint) -> CGMutablePathRef {
        let keypathPoints = NSMutableArray()
        let high = size.height + padding
        let direction: CGFloat = startBubblesFromTop ? -1 : 1

        var newPoint = startPosition

        while newPoint.y <= high && newPoint.y >= -padding {
            let deltaY = ((CGFloat(rand()) / CGFloat(RAND_MAX)) * 20) + 50
            let deltaX = ((CGFloat(rand()) / CGFloat(RAND_MAX)) * 60) - 30

            newPoint = CGPointMake(newPoint.x + deltaX, newPoint.y + direction * deltaY)

            let value = NSValue(CGPoint: newPoint)
            keypathPoints.addObject(value)
        }

        let mutablePath = CGPathCreateMutable()

        print(keypathPoints)

        if keypathPoints.count > 0 {
            let firstPoint = (keypathPoints.objectAtIndex(0) as! NSValue).CGPointValue()

            CGPathMoveToPoint(mutablePath, nil, firstPoint.x, firstPoint.y)

            var point = firstPoint
            var nextPoint: CGPoint

            for var i = 0; i < keypathPoints.count - 1; i++ {
                nextPoint = (keypathPoints[i + 1] as! NSValue).CGPointValue()

                let midPoint = CGPointMake((point.x + nextPoint.x) / 2, (point.y + nextPoint.y) / 2)
                CGPathAddQuadCurveToPoint(mutablePath, nil, point.x, point.y, midPoint.x, midPoint.y)
                point = nextPoint
            }
        }

        return mutablePath
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if poppable {
            for touch in touches {
                let location = (touch as UITouch).locationInNode(self)
                let bubble = self.nodeAtPoint(location)
                if bubble.name == bubbleName {
                    (bubble as! SKSpriteNode).texture = SKTexture(imageNamed: "bubblePop")

                    let scale = SKAction.scaleTo(0, duration: NSTimeInterval(0.2))
                    let remove = SKAction.removeFromParent()
//                let sound = SKAction.playSoundFileNamed("", waitForCompletion: false)
                    let sequence = SKAction.sequence([scale, remove])
                    bubble.runAction(sequence)
                }
            }
        }
    }
}
