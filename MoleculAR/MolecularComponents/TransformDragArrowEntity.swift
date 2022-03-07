//
//  TransformDragArrowEntity.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/18/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import RealityKit




class TransformDragArrowEntity: Entity, HasModel, HasCollision {
    
    static let modelSize = Float(0.5)

    enum Direction {
        case UP
        case DOWN
        case XPLUS
        case XNEG
        case ZPLUS
        case ZNEG
    }
    required init(direction: Direction, material: Material) {
        
        super.init()

        
        let model = try! Entity.loadModel(named: "Arrow")
        
        
        let mesh = model.model!.mesh
        
        let newModel = ModelComponent(mesh: mesh, materials: [material])
        
        self.model = newModel
        
        
            
        switch direction {
        case .UP:
            self.transform = Transform(pitch: -.pi/2, yaw: 0, roll: 0)

        case .DOWN:
            self.transform = Transform(pitch: .pi/2, yaw: 0, roll: 0)

        case .XPLUS:
            self.transform = Transform(pitch: 0, yaw: .pi/2, roll: 0)

        case .XNEG:
            self.transform = Transform(pitch: 0, yaw: -.pi/2, roll: 0)

        case .ZPLUS:
            self.transform = Transform(pitch: 0, yaw: 0, roll: 0)

        case .ZNEG:
            self.transform = Transform(pitch: 0 , yaw: .pi, roll: 0)
        }
        
        let transform = Transform(pitch: .pi/2, yaw: 0, roll: 0)
        
        let capsule = ShapeResource.generateCapsule(height: 3, radius: 0.5).offsetBy(rotation: transform.rotation)
        
        self.collision = CollisionComponent(shapes: [capsule])
        self.scale = [TransformDragArrowEntity.modelSize, TransformDragArrowEntity.modelSize, TransformDragArrowEntity.modelSize]
        
        
        
        
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
