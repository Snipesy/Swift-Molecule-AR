//
//  MoleecualrArView$Gesture.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/14/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import RealityKit
import ARKit
import Combine
import SwiftUI


extension MolecularARView {
    

    
    func setupMainGestures() {

        
        let tapRecognzier = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        
        let transformController = TransformGestureController(target: self)

        self.addGestureRecognizer(tapRecognzier)
                
        self.addGestureRecognizer(transformController)
        
        self.addGestureRecognizer(self.cameraController)

        self.cameraController.require(toFail: transformController)
        transformController.require(toFail: tapRecognzier)
        

        
    }

    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
                
        guard let touchInView = sender?.location(in: self) else {
          return
        }
        
        

        let transform = self.entity(at: touchInView)
        
        
        
        guard let atomTapped = transform as? AtomEntity else {
            
          // not a atom
          self.dragEntity.removeFromParent()

          return
        }
        
        
        self.lastAtomTapped?.removeSelectedEffect()
        
        self.dragEntity.removeFromParent()
        
        atomTapped.addSelectedEffect()
        
        atomTapped.addChild(dragEntity)
        
        self.lastAtomTapped = atomTapped
        
        
    }
    

    
}
