//
//  ContentView.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/12/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import SwiftUI
import RealityKit

struct MoleculeView: View {
    
    var name: String
    
    init(moleculeModel: MoleculeModel) {
        self.controller = ArController()
        self.name = moleculeModel.name
        self.controller.setMolecule(molecule: moleculeModel)
    }
        
    let controller: ArController
    @State var isVrMode = false

    var body: some View {
        ZStack {
            controller
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Button(action: {
                        if (self.isVrMode) {
                            self.isVrMode = false
                            self.controller.setupForNonAr()
                        } else {
                            self.isVrMode = true
                            self.controller.setupForAr()
                        }
                    }) {
                        Text("TOGGLE")
                    }
                }
            }
        }
        .navigationBarTitle(self.name, displayMode: .inline)
            
    }
}


struct ContentView : View {
    
    var body: some View {

        NavigationView {
            List(MoleculeModel.getModels()) { it in
                NavigationLink(destination: MoleculeView(moleculeModel: it)) {
                    VStack(alignment: .leading) {
                        Text(it.name)
                        Text(it.file).font(.caption)
                    }.padding(5)
                }
               
            }
        }.navigationTitle("Select Molecule")
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
