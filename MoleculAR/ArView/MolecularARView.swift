//
//  MolecularARView.swift
//  MoleculAR
//
//  Created by Justin Hoogestraat on 9/13/20.
//  Copyright © 2020 Surreal Development LLC. All rights reserved.
//

import RealityKit
import ARKit
import Combine
import SwiftUI

enum MolecularARViewStatus {
    case initCoaching
    case positioning
    case planeSearching
}


final class ArController: UIViewRepresentable {
    
    
    weak var currentArView: MolecularARView?
     func makeUIView(context: Context) -> MolecularARView {
        
        let arView = MolecularARView()
        
        self.currentArView = arView
        arView.addCoaching()
        arView.setupMainGestures()
        
        
        // debug
        //arView.debugOptions.insert(.showPhysics)
        //arView.debugOptions.insert(.showStatistics)

        
        
        setupForNonAr()
        
        return arView
    }
    

    
    static func dismantleUIView(_ uiView: MolecularARView, coordinator: ()) {
        uiView.cleanup()
        uiView.session.pause()
        uiView.removeFromSuperview()
    }
    
    var defaultMolecule: MoleculeModel = MoleculeModel.Caffeine()
    
    func setMolecule(molecule: MoleculeModel) {
        self.defaultMolecule = molecule
    }
    
    func setupForAr() {
        
        guard let arView = currentArView else {
            return
        }
        
        let config = ARWorldTrackingConfiguration()
        
        
        arView.cleanup()
        
        arView.coachingOverlay.activatesAutomatically = true
        config.planeDetection = .horizontal

        
        arView.cameraMode = .ar

        arView.session.run(config, options: [.resetTracking])

        arView.session.delegate = arView
        
        
        let anchorPlane = AnchoringComponent.Target.plane(
          .horizontal,
          classification: .any,
          minimumBounds: [0.3,0.3])
        
        let anchor = AnchorEntity(anchorPlane)
        
        arView.currentMainAnchor = anchor
        arView.scene.anchors.append(anchor)
        
        arView.addMolecule(moleculeModel: self.defaultMolecule)
        
    }
    

    
    func setupForNonAr() {
        guard let arView = currentArView else {
            return
        }
    
        arView.cleanup()
        
        arView.cameraMode = .nonAR
        
        arView.coachingOverlay.activatesAutomatically = false
        arView.coachingOverlay.setActive(false, animated: false)
        
        
        let anchor = AnchorEntity(world: [0,0,0])
        
        arView.currentMainAnchor = anchor
        
        arView.scene.anchors.append(anchor)
        
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config, options: [.resetTracking])
        
        
        arView.session.delegate = arView


        
        // add camera
        
        arView.scene.anchors.append(arView.cameraController.cameraAnchor)
        arView.addMolecule(moleculeModel: self.defaultMolecule)
        
    }
    
    func updateUIView(_ uiView: MolecularARView, context: Context) {}

    
    
    
}

    
    

class MolecularARView: ARView, ARSessionDelegate {
    let coachingOverlay = ARCoachingOverlayView()
    
    var tableAdded = false
    
    var waitForAnchor: Cancellable?
    
    var currentMolecule: Molecule?
    
    var currentMainAnchor: AnchorEntity?
    
    let cameraController = NonArCameraController()
    
    
    var lastAtomTapped: AtomEntity?

    let dragEntity = TransformDragEntity()
    
    var status: MolecularARViewStatus = .initCoaching {
      didSet {
        switch oldValue {
        case .positioning:
          changedFromPositioningStatus()
        default:
          print("status was: \(status)")
        }
        switch status {
        case .positioning:
          setToPositioningStatus()
        default:
          print("status is: \(status)")
        }
      }
    }
    
    func cleanup() {
        self.waitForAnchor?.cancel()
        self.scene.anchors.removeAll()
    }
    
    
    
    func addMolecule(moleculeModel: MoleculeModel) {
        
        let molecule = Molecule(model: moleculeModel)
        self.status = .planeSearching

        self.waitForAnchor = self.scene.subscribe(
            to: SceneEvents.AnchoredStateChanged.self,
            on: molecule
        ) { event in
            if event.isAnchored {
                self.status = .positioning
                DispatchQueue.main.async {
                    self.waitForAnchor?.cancel()
                    self.waitForAnchor = nil
            }
          }
        }
        
        self.currentMolecule = molecule
        
        if (self.cameraMode == .ar) {
            molecule.setPosition([0, molecule.lowestAtomOffsetPosition(), 0], relativeTo: nil)
        }
        
        // anchor
                
        
        currentMainAnchor?.addChild(molecule)
        
    }

}



extension MolecularARView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        self.coachingOverlay.delegate = self
        self.coachingOverlay.session = self.session
        self.coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // MARK: CoachingGoal
        self.coachingOverlay.goal = .horizontalPlane
      
        self.addSubview(self.coachingOverlay)
    }

    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        
    }
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        
        if (self.cameraMode == .ar) {
            cleanup()
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            session.run(configuration, options: [.resetTracking])
        }
        
    }

}
    
extension MolecularARView {

  func changedFromPositioningStatus() {
    //self.flipTable?.collision = nil
    //self.confirmButton?.removeFromParent()
    //self.installedGestures = self.installedGestures.filter({ (recogniser) -> Bool in
    //  recogniser.isEnabled = false
    //  return false
    //})
  }
  func setToPositioningStatus() {
    
    print("SET TO POSITIION")
    
    guard let molecule = self.currentMolecule else {
        return
    }
    
    //molecule.collision = CollisionComponent(shapes: [.generateBox(size: [4, 1, 4])])
    
    

  }
}
