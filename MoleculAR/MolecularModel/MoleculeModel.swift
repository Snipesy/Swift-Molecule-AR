//
//  File.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/14/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import Foundation


class MoleculeModel: Identifiable {
    let name: String
    let file: String
    let atoms: [AtomModel]
    let bonds: [BondModel]
    
    init(atoms: [AtomModel], bonds: [BondModel], name: String, file: String) {
        self.atoms = atoms
        self.bonds = bonds
        self.name = name
        self.file = file
    }
}
