//
//  File.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/13/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import RealityKit
import UIKit
import Combine

class AtomEntity: Entity, HasModel, HasCollision{
    
    let atomModel: AtomModel
    
    private var selectEffect: Entity?
    
    private var cancellables = Set<AnyCancellable>()

    
    deinit {
        self.cancellables.forEach { (a) in
            a.cancel()
        }
    }
    
    
    init(model: AtomModel) {
        self.atomModel = model

        super.init()
        
        self.model = ModelCache.getAtomModel(forElement: model.element)
        
        self.position = model.position
        
        self.collision = ModelCache.getAtomCollisionModel(forElement: model.element)
        
        let c = model.$position.sink { (newPosition) in
            self.position = newPosition
        }
        c.store(in: &self.cancellables)
        
    }
    
    
    func addSelectedEffect() {
        
        let color = self.atomModel.element.cpkColor().withAlphaComponent(0.5)
        
        let material = SimpleMaterial(color: color, isMetallic: false)
                
        let glow = ModelEntity(
            mesh: .generateSphere(radius: self.atomModel.element.workingSize() * 1.2),
        materials: [material])
        
        self.addChild(glow)
        
        self.selectEffect = glow
    }
    
    func removeSelectedEffect() {
        guard let effect = self.selectEffect else {
            return
        }
        
        self.removeChild(effect)
        self.selectEffect = nil
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
