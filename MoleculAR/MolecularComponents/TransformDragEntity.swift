//
//  TransformDragEntity.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/18/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import RealityKit
import SwiftUI

class TransformDragEntity: Entity {
    
    static let red = SimpleMaterial(color: UIColor.red, isMetallic: false)
    static let blue = SimpleMaterial(color: UIColor.blue, isMetallic: false)
    static let green = SimpleMaterial(color: UIColor.green, isMetallic: false)


    static let radii = Float(0.5)
    
    

    let down = TransformDragArrowEntity(direction: .DOWN, material: TransformDragEntity.red)

    let up = TransformDragArrowEntity(direction: .UP, material: TransformDragEntity.red)

    let x1 = TransformDragArrowEntity(direction: .XPLUS, material: TransformDragEntity.green)
    let x2 = TransformDragArrowEntity(direction: .XNEG, material: TransformDragEntity.green)


    let z1 = TransformDragArrowEntity(direction: .ZPLUS, material: TransformDragEntity.blue)
    let z2 = TransformDragArrowEntity(direction: .ZNEG, material: TransformDragEntity.blue)


    
    required init() {
        self.up.position = [0,TransformDragEntity.radii, 0]
        self.down.position = [0,-1 * TransformDragEntity.radii, 0]
        self.x1.position = [ TransformDragEntity.radii, 0, 0]
        self.x2.position = [ TransformDragEntity.radii * -1, 0, 0]
        self.z1.position = [ 0, 0, TransformDragEntity.radii]
        self.z2.position = [ 0, 0, TransformDragEntity.radii * -1]
        
        super.init()
        

        
        self.addChild(self.up)
        self.addChild(self.down)
        self.addChild(self.x1)
        self.addChild(self.x2)
        self.addChild(self.z1)
        self.addChild(self.z2)
        
    }
}
