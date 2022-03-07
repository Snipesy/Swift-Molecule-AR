//
//  CmlImport.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/15/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import Foundation


extension MoleculeModel {
    static func Caffeine() -> MoleculeModel {
        return MoleculeModel.fromFile(fileName: "caffeine")
    }
    
    static func fromFile(fileName: String) -> MoleculeModel {
        let path = Bundle.main.path(forResource: fileName, ofType: "cml")!
        let cml = CmlImport(fromPath: URL(fileURLWithPath: path))
        return cml.parsedMolecule
    }
    
    static func getModels() -> [MoleculeModel] {
        let paths = Bundle.main.paths(forResourcesOfType: "cml", inDirectory: nil)
        let cmls = paths.map { it -> MoleculeModel in
            let cml = CmlImport(fromPath: URL(fileURLWithPath: it))
            return cml.parsedMolecule
        }
        return cmls
    }
    
}
class CmlImport: NSObject, XMLParserDelegate {
    
    
    private var atomBuffer = [String : AtomModel]()
    private var bondBuffer = [BondModel]()
    private var name: String = "no name"
    private var fileName: String = "no file name"

    private var itemContents: String = ""
    
    var parsedMolecule = MoleculeModel(atoms: [AtomModel](), bonds: [BondModel](), name: "TEMP", file: "Temp")
    
    init(fromPath: URL) {
        super.init()
        
        let xml = XMLParser(contentsOf: fromPath)
        
        xml?.delegate = self
        self.fileName = fromPath.lastPathComponent
        xml?.parse()

    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        itemContents.append(contentsOf: string)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
                if (elementName == "atom") {
            let element = attributeDict["elementType"]!
            let id = attributeDict["id"]!
            let x = Float(attributeDict["x3"]!)!
            let y = Float(attributeDict["y3"]!)!
            let z = Float(attributeDict["z3"]!)!
            
            atomBuffer[id] = AtomModel(element: Element.fromString(name: element), position: [x,y,z])
        }
        if (elementName == "bond") {
            let atomSplit = attributeDict["atomRefs2"]!.split(separator: " ", omittingEmptySubsequences: true)
            
            let atom1 = atomBuffer[String(atomSplit[0])]!
            let atom2 = atomBuffer[String(atomSplit[1])]!
            
            let order = Int(attributeDict["order"]!)!
            
            let bond = BondModel(a: atom1, b: atom2, bond: order)
            
            atom1.associatedBonds.append(bond)
            atom2.associatedBonds.append(bond)
            
            bondBuffer.append(bond)
            
        }
        itemContents = ""
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if (elementName == "name") {
            self.name = itemContents
        }

        itemContents = ""

    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        self.parsedMolecule = MoleculeModel(atoms: Array(atomBuffer.values), bonds: bondBuffer, name: self.name, file: self.fileName)
    }
    
}
