//
//  GameViewController+ARSCNViewDelegate.swift
//  Multiplayer_test
//
//  Created by Shawn Ma on 10/1/18.
//  Copyright © 2018 Shawn Ma. All rights reserved.
//

import ARKit
import os.log

extension GameViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    // MARK: - Focus Square
    
    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
        }
        
        if let camera = arscnView.session.currentFrame?.camera, case .normal = camera.trackingState , let result = self.arscnView.hitTest(self.screenCenter, types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane, .estimatedVerticalPlane]).first {
            DispatchQueue.main.async {
                self.arscnView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(hitTestResult: result, camera: camera)
            }
        } else {
            DispatchQueue.main.async {
                self.focusSquare.state = .initializing
                self.arscnView.pointOfView?.addChildNode(self.focusSquare)
            }
        }
    }
    
    // MARK: - AR session management
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
//
//        switch trackingState {
//        case .normal where frame.anchors.isEmpty && multipeerSession.connectedPeers.isEmpty:
//            // No planes detected; provide instructions for this app's AR interactions.
//            message = "Move around to map the environment, or wait to join a shared session."
//
////        case .normal where !game.connectedPeers.isEmpty && mapProvider == nil:
////            let peerNames = multipeerSession.connectedPeers.map({ $0.displayName }).joined(separator: ", ")
////            message = "Connected with \(peerNames)."
//
//        case .notAvailable:
//            message = "Tracking unavailable."
//
//        case .limited(.excessiveMotion):
//            message = "Tracking limited - Move the device more slowly."
//
//        case .limited(.insufficientFeatures):
//            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
//
//        case .limited(.initializing) where mapProvider != nil,
//             .limited(.relocalizing) where mapProvider != nil:
//            message = "Received map from \(mapProvider!.displayName)."
//
//        case .limited(.relocalizing):
//            message = "Resuming session — move to where you were when the session was interrupted."
//
//        case .limited(.initializing):
//            message = "Initializing AR session."
//
//        default:
//            // No feedback needed when tracking is normal and planes are visible.
//            // (Nor when in unreachable limited-tracking states.)
//            message = ""
//
//        }
//
//        sessionInfoLabel.text = message
//        sessionInfoView.isHidden = message.isEmpty
    }
    
    
    
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare(isObjectVisible: !self.padView.isHidden)
        }
        
        
        os_signpost(.begin, log: .render_loop, name: .render_loop, signpostID: .render_loop,
                    "Render loop started")
        os_signpost(.begin, log: .render_loop, name: .logic_update, signpostID: .render_loop,
                    "Game logic update started")
        
        if let gameManager = self.gameManager, gameManager.isInitialized {
            GameTime.updateAtTime(time: time)
            gameManager.update(timeDelta: GameTime.deltaTime)
        }
        
        os_signpost(.end, log: .render_loop, name: .logic_update, signpostID: .render_loop,
                    "Game logic update finished")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // should init plane here
        //        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//        if let name = anchor.name, name.hasPrefix("tank") {
//            DispatchQueue.main.async {
//                let tank = self.loadTank()
//                tank.scale = SCNVector3(0.0002, 0.0002, 0.0002)
//                if self.myTank == nil {
//                    self.myTank = tank
//                } else {
//                    self.otherTank = tank
//                }
//                node.addChildNode(tank)
//            }
//        }
        
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        switch frame.worldMappingStatus {
//        case .notAvailable, .limited:
//            sendMapButton.isEnabled = false
//        case .extending:
//            sendMapButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
//        case .mapped:
//            sendMapButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
//        }
        mappingStatusLabel.text = frame.worldMappingStatus.description
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        //        resetTracking(nil)
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    
}
