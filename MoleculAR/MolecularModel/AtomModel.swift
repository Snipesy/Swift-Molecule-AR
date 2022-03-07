//
//  Atom.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/14/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import Foundation
import simd
import SwiftUI
import Combine


enum Element {
    case Hydrogen
    case Helium
    case Carbon
    case Nitrogen
    case Oxygen
    case Phosphorus
    case Unknown
    
    static func fromString(name: String) -> Element {
        switch (name) {
            case "H":
                return Element.Hydrogen
            case "He":
                return Element.Helium
            case "C":
                return Element.Carbon
            case "N":
                return Element.Nitrogen
            case "O":
                return Element.Oxygen
            case "P":
                return Element.Phosphorus
            default:
                return Element.Unknown
        }
    }
    
    /** This is the periodic radii. The radii is used to determine when covalent bonding should occur
     Units are in å (10^-10 m)
     */
    func periodicRadii() -> Float {
        switch (self) {
            case Element.Hydrogen:
                return 0.31
            case Element.Helium:
                return 0.28
            case Element.Carbon:
                return 0.76
            case Element.Nitrogen:
                return 0.71
            case Element.Oxygen:
                return 0.66
            case Element.Phosphorus:
                return 1.07
            default:
                return -1.0
        }
    }
    
    func workingSize() -> Float {
        switch (self) {
            case Element.Hydrogen:
                return 0.15
            case Element.Helium:
                return 0.15
            case Element.Carbon:
                return 0.3
            case Element.Nitrogen:
                return 0.3
            case Element.Oxygen:
                return 0.3
            case Element.Phosphorus:
                return 0.4
            default:
                return 0.3
        }
    }
    
    func cpkColor() -> UIColor {
        switch (self) {
            case Element.Hydrogen:
                return UIColor.white
            case Element.Helium:
                return UIColor.purple
            case Element.Carbon:
                return UIColor.gray
            case Element.Nitrogen:
                return UIColor.blue
            case Element.Oxygen:
                return UIColor.red
            case Element.Phosphorus:
                return UIColor.orange
            default:
                return UIColor.green
        }
    }
    
    func valency() -> Int {
        switch (self) {
            case Element.Hydrogen:
                return 1
            case Element.Helium:
                return 0
            case Element.Carbon:
                return 4
            case Element.Nitrogen:
                return 3
            case Element.Oxygen:
                return 2
            case Element.Phosphorus:
                return 4
            default:
                return 1
        }
    }
}





class AtomModel: ObservableObject {
    let element: Element
    @Published var position: SIMD3<Float>
    
    var associatedBonds = [BondModel]()
    var unshownBonds = 0
    
    static func distanceBetween(a: AtomModel, b: AtomModel) -> Float {
        return sqrt(pow(a.position.x-b.position.x, 2) + pow(a.position.y-b.position.y,2) + pow(a.position.z-b.position.z, 2))
    }
    
    static func midPointAtoms(a: AtomModel, b: AtomModel) -> SIMD3<Float> {
        let c1 = (a.position.x + b.position.x) / 2.0
        let c2 = (a.position.y + b.position.y) / 2.0
        let c3 = (a.position.z + b.position.z) / 2.0
        
        return [c1,c2,c3]
        
    }
    
    // How many more 'bonds' this atom wants to fill its octet.
    func currentValency() -> Int {
        let bonds = associatedBonds.sumBy { (bond) -> Int in
            bond.bond + self.unshownBonds
        }
        
        return self.element.valency() - bonds
    }
    
    // How many more 'bonds' this atom could hypotethically have with its neigbors
    func potentialValency() -> Int {
        let neighbors = self.associatedNeighbors()
        
        let potential = neighbors.sumBy { (atom) -> Int in
            atom.currentValency()
        }
        
        return potential
    }
    
    func associatedNeighbors() -> [AtomModel] {
        return associatedBonds.map { (bond) -> AtomModel in
            if (bond.atomA === self) {
                return bond.atomB
            } else {
                return bond.atomA
            }
        }
    }
    
    init(element: Element, position: SIMD3<Float>) {
        self.element = element
        self.position = position
        
    }
}
