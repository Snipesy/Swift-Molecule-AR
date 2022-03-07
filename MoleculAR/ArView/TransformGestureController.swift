//
//  TransformGestureController.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/23/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import SwiftUI
import RealityKit

class TransformGestureController: UIGestureRecognizer {
    
    
    
    private let factor = Float(0.01)
    private let target: MolecularARView
    
    private var requiresFailureOf: UIGestureRecognizer? = nil
    
    enum State {
        case none
        case updown
        case xaxis
        case zaxis
    }
    
    var gestureState: State = .none
    
    init(target: MolecularARView) {
        self.target = target

        super.init(target: target, action: nil)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        

        if self.state == .failed || self.requiresFailureOf?.state ?? .failed != .failed {
            return
        }
        
        let newTouch = touches.first

        let newPoint = (newTouch?.location(in: self.view))!
        let previousPoint = (newTouch?.previousLocation(in: self.view))!
        
        
        guard let transformTarget = self.target.lastAtomTapped else {
            self.state = .failed
            return
        }
        
        // change deltas based on current camera
        
        
       
        
        var deltaX = Float(newPoint.x - previousPoint.x) * self.factor
        var deltaY = Float(newPoint.y - previousPoint.y) * self.factor
        
        self.state = .changed
        
        
        
        // this will tell us if the camera is flipped
        // in which case values must be inverted
        let matrix = target.cameraTransform.matrix
        
        let yFlipped = matrix[1][1] < 0

        if (yFlipped) {
            // if flipped dont reverse
        } else {
            deltaY = deltaY * -1.0
            deltaX = deltaX * -1.0
        }
        
        
        var deltaZ = deltaX
       
        let targetPosition = transformTarget.position
        
        // do some angular analysis on the target

                
        let cameraPosition = transformTarget.convert(transform: target.cameraTransform, to: transformTarget).translation
        
        
        // we can deduce how we are looking at this atom purely on position.
        if (cameraPosition.y > targetPosition.y) {
            // we are above
        } else {
            // we are below
        }
        
        if (cameraPosition.x > targetPosition.x) {
            // we are looking at it such that raw x values work
        } else {
            // invert x
            deltaZ = deltaZ * -1.0

        }
        
        if (cameraPosition.z > targetPosition.z) {
            deltaX = deltaX * -1.0

        } else {
            // nothing
        }
        
        
        switch self.gestureState {
        case .updown:
            
            transformTarget.atomModel.position = [transformTarget.position.x, transformTarget.position.y + deltaY, transformTarget.position.z]
        case .xaxis:
            transformTarget.atomModel.position = [transformTarget.position.x + deltaX, transformTarget.position.y, transformTarget.position.z]
        case .zaxis:
            transformTarget.atomModel.position = [transformTarget.position.x, transformTarget.position.y, transformTarget.position.z + deltaZ]
        default:
            break
        }
        
        
        
        
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        
        guard let touchInView = touches.first?.location(in: target) else {
          return
        }

        let test = target.hitTest(touchInView, query: .all, mask: .all)
        
        let filtered = test.filter { (hit) -> Bool in
            hit.entity !== self.target.lastAtomTapped
        }
        
        let direction = filtered.first
        
        
        if (direction == nil) {
            self.state = .failed
            return
        }
        
        let entity = direction!.entity
        
        
        if (entity === target.dragEntity.up || entity === target.dragEntity.down) {
            self.gestureState = .updown
            self.state = .began
        }
        else if (entity === target.dragEntity.x1 || entity === target.dragEntity.x2) {
            self.gestureState = .xaxis
            self.state = .began
        }
        else if (entity === target.dragEntity.z1 || entity === target.dragEntity.z2) {
            self.gestureState = .zaxis
            self.state = .began
        }
        else {
            self.state = .failed
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.gestureState = .none
        
        
        if self.state == .changed {
            self.state = .recognized
        } else {
            self.state = .failed
        }
        
    }
    
    
    override func shouldRequireFailure(of otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        self.requiresFailureOf = otherGestureRecognizer
        return true
    }
    
    
    
    
    
}
