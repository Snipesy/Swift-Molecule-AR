//
//  Molecule.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/14/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import RealityKit
import ARKit


class Molecule: Entity {
    
    let model: MoleculeModel
    func lowestAtomOffsetPosition() -> Float {
        let lowestAtom = self.model.atoms.min { (a, b) -> Bool in
            a.position.y < b.position.y
        }
        print (lowestAtom!.position)
        // offset ourselves by the lowest
        return (lowestAtom?.position.y ?? 0.0) * self.scale.y * -1.0 
    }

    
    required init(model: MoleculeModel) {
        self.model = model

        super.init()
        
        
        model.atoms.forEach { (atom) in
            let entity = AtomEntity(model: atom)
            self.addChild(entity)
        }
        
        model.bonds.forEach { (bond) in
            let entity = Bond(bondModel: bond)
            self.addChild(entity)
        }
        
        
        self.scale = [0.1,0.1,0.1]
        
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    

}
