//
//  Bond.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/14/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import Foundation



class BondModel {
    
    let atomA: AtomModel
    let atomB: AtomModel
    var bond: Int
    
    
    init(a: AtomModel, b: AtomModel, bond: Int = 1) {
        self.atomA = a
        self.atomB = b
        self.bond = bond
    }
}
