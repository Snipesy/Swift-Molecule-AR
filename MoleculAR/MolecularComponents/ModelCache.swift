//
//  AtomModels.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/15/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import RealityKit
import SwiftUI


fileprivate extension UIColor {
    func toMaterial(isMetallic: Bool = false) ->  RealityFoundation.Material {
    return SimpleMaterial(color: self, isMetallic: isMetallic)
  }
}


class ModelCache {
    
    private static var modelCache = [Element : ModelComponent]()
    
    private static var modelCollisionCache = [Element : CollisionComponent]()

    
    static func getAtomModel(forElement: Element) -> ModelComponent {
        let hit = modelCache[forElement]
        
        if (hit == nil) {
            let miss = ModelComponent(
                mesh: .generateSphere(radius: forElement.workingSize()),
            materials: [forElement.cpkColor().toMaterial()])
            modelCache[forElement] = miss
            return miss
        } else {
            return hit!
        }
    }
    
    static func getAtomCollisionModel(forElement: Element) -> CollisionComponent {
        
        let hit = modelCollisionCache[forElement]
        
        if (hit == nil) {
            let miss = CollisionComponent(shapes: [.generateSphere(radius: forElement.workingSize())])
            modelCollisionCache[forElement] = miss
            return miss
        } else {
            return hit!
        }
    }
}
