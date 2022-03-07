//
//  NonArCameraController.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/14/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import SwiftUI
import RealityKit


class NonArCameraController: UIGestureRecognizer {
    
   
    
    var cameraDistance: Float = 1
    var cameraXRadians: Float = 0
    var cameraYRadians: Float = 3.1415926/2
    
    let camera = PerspectiveCamera()
    let cameraAnchor = AnchorEntity(world: [0, 0, 1])
    
    private var requiresFailureOf: UIGestureRecognizer? = nil


    
    enum GestureState {
        case none
        case zoom
        case rotate
    }
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        
        cameraAnchor.addChild(camera)
    }
    
    
    var gestureState: GestureState = .none
    
    func rotate(_ touches: Set<UITouch>, with event: UIEvent) {
        let newTouch = touches.first

        let newPoint = (newTouch?.location(in: self.view))!
        let previousPoint = (newTouch?.previousLocation(in: self.view))!
                
        // move camera on x axis based on delta
        let deltaX = Float(newPoint.x - previousPoint.x)
        let deltaY = Float(newPoint.y - previousPoint.y) * -1.0
        
        
        self.cameraYRadians = self.cameraYRadians + deltaY/100
        
        // setup limits
        if (self.cameraYRadians > 3.14 * 0.9)
        {
            self.cameraYRadians = 3.14 * 0.9
        }
        else if (self.cameraYRadians < 3.14 * 0.1)
        {
            self.cameraYRadians = 3.14 * 0.1
        }
        
        self.cameraXRadians = self.cameraXRadians + deltaX/100
        
        
        self.updateCam()
        
    }
    
    func updateCam() {
        let z = self.cameraDistance * sin(self.cameraYRadians) * sin(self.cameraXRadians)
        let x = self.cameraDistance * sin(self.cameraYRadians) * cos(self.cameraXRadians)
        let y = self.cameraDistance * cos(self.cameraYRadians)
        
        self.cameraAnchor.look(at: SIMD3(0,0,0), from: SIMD3(x,y,z), relativeTo: nil)
    }
    
    
    func zoom(_ touches: Set<UITouch>, with event: UIEvent) {
        let newPoint1 = (touches.first!.location(in: self.view))
        let previousPoint1 = (touches.first!.previousLocation(in: self.view))
        
        let point2Index = touches.index(touches.startIndex, offsetBy: 1)
        let newPoint2 = (touches[point2Index].location(in: self.view))
        let previousPoint2 = (touches[point2Index].previousLocation(in: self.view))
        
        let prevDistance = sqrt(pow(previousPoint2.x-previousPoint1.x, 2) + pow(previousPoint2.y-previousPoint1.y, 2))
        let newDistance = sqrt(pow(newPoint2.x-newPoint1.x, 2) + pow(newPoint2.y-newPoint1.y, 2))
        
        let changed = newDistance - prevDistance
        
        self.cameraDistance = self.cameraDistance + Float(changed/100) * -1.0
        
        if (self.cameraDistance < 0.5) {
            self.cameraDistance = 0.5
        }
        else if (self.cameraDistance > 50) {
            self.cameraDistance = 100
        }
        
        self.updateCam()

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        if self.state == .failed || self.requiresFailureOf?.state ?? .failed != .failed {
            return
        }
        
        if (touches.count == 2) {
            self.gestureState = .zoom
            zoom (touches, with: event)
            self.state = .changed

            
        }
        else if (touches.count == 1 && (self.gestureState == .rotate || self.gestureState == .none)) {
            self.gestureState = .rotate
            rotate(touches, with: event)
            self.state = .changed
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
       super.touchesEnded(touches, with: event)
        
        self.gestureState = .none

        
        if self.state == .began || self.state == .changed {
            self.state = .recognized
        } else {
            self.state = .failed
        }
       
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
                
        if self.state == .possible {
            //self.state = .began
        }
    }

    
    
    
    override func reset() {
        super.reset()
        self.gestureState = .none
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.gestureState = .none
        state = .cancelled
    }
    
    override func shouldRequireFailure(of otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        self.requiresFailureOf = otherGestureRecognizer
        return true
    }
    


}
