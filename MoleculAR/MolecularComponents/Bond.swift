//
//  Bond.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/14/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import RealityKit
import SwiftUI
import SceneKit
import Combine


fileprivate extension UIColor {
    func toMaterial(isMetallic: Bool = false) -> RealityFoundation.Material {
    return SimpleMaterial(color: self, isMetallic: isMetallic)
  }
}

class BondModelEntity: Entity, HasModel {
    
    static let box = MeshResource.generateBox(width: 0.1, height: 0.1, depth: 1.0, cornerRadius: 0.1, splitFaces: false)
    static let mesh = ModelComponent(mesh: box, materials: [UIColor.lightGray.toMaterial()])
    static let collisionComponent = CollisionComponent(shapes: [ShapeResource.generateConvex(from: box)])
    
    required init() {
        super.init()
        self.model = BondModelEntity.mesh
    }
}

class DoubleBondModelEntity: Entity {

    required init() {
        super.init()

        let a = BondModelEntity()
        let b = BondModelEntity()
        a.position.x = 0.1
        b.position.x = -0.1
        
        self.addChild(a)
        self.addChild(b)
    }
}

class Bond: Entity {
    
    let bondModel: BondModel
    
    private var cancellables = Set<AnyCancellable>()
    
    
    deinit {
        self.cancellables.forEach { (a) in
            a.cancel()
        }
    }
    
    
    init(bondModel: BondModel) {
        
        self.bondModel = bondModel

        
        super.init()
        
        
        // add models depending on bond type
        if (bondModel.bond == 2) {
            self.addChild(DoubleBondModelEntity())
        } else {
            self.addChild(BondModelEntity())
        }
        
        
        
                
        self.reposition()
        
        
        // make observers
        bondModel.atomA.$position.sink { (_) in
            self.reposition()
        }.store(in: &self.cancellables)
        
        bondModel.atomB.$position.sink { (_) in
            self.reposition()
        }.store(in: &self.cancellables)
        
    }
    
    func reposition() {
        // make cylllinder between positions
        let distance = AtomModel.distanceBetween(a: bondModel.atomA, b: bondModel.atomB)
        
        // use scale for faster speed
        self.scale = [1, 1, distance]
        
        var midpoint = AtomModel.midPointAtoms(a: bondModel.atomA, b: bondModel.atomB)
        // just look at one of the atoms from this midpoint
        self.position = midpoint
        
        // Bug fix for looking directly up or down
        if (bondModel.atomA.position.x == midpoint.x && bondModel.atomB.position.z == midpoint.z) {
            // add bias
            midpoint = [midpoint.x + 0.0001, midpoint.y, midpoint.z]
        }
        
        self.look(at: bondModel.atomA.position, from: midpoint, upVector: [0,1,0], relativeTo: parent)

    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
}
