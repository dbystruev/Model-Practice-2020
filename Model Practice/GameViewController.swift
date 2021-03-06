//
//  GameViewController.swift
//  Model Practice
//
//  Created by Denis Bystruev on 10.09.2020.
//  Copyright © 2020 Denis Bystruev. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    // MARK: - Stored Properties
    
    // The score
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // Animation duration time in seconds (the smaller - the faster)
    var duration: CFTimeInterval = 5
    
    // The scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!
    
    // The ship
    var ship: SCNNode!
    
    // The tap gesture
    var tapGesture: UITapGestureRecognizer!
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remove the ship
        removeShip()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // span the ship
        spanShip()
    }
    
    func removeShip() {
        getShip?.removeFromParentNode()
    }
    
    func spanShip() {
        // retrieve the ship node
        ship = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.clone()
        
        // add ship to the scene
        scene.rootNode.addChildNode(ship)
        
        // position the ship
        let x = Float.random(in: -25 ... 25)
        let y = Float.random(in: -25 ... 25)
        let z = Float(-105)
        let position = SCNVector3(x, y, z)
        ship.position = position
        
        // set the ship look at
        let lookAtPosition = SCNVector3(2 * x, 2 * y, 2 * z)
        ship.look(at: lookAtPosition)
        
        // animate the 3d object
        ship.runAction(SCNAction.move(to: SCNVector3(), duration: duration)) {
            // Game lost — remove gesture recognizer, the ship and put label about it
            self.removeShip()
            
            DispatchQueue.main.async {
                self.scnView.removeGestureRecognizer(self.tapGesture)
                self.scoreLabel.text = "You lost!\nYour score: \(self.score)"
            }
        }
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.25
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                // Remove the ship
                self.ship.removeAllActions()
                self.removeShip()
                
                // Add the score
                self.score += 1
                
                // Change the time interval
                self.duration *= 0.9
                
                // Span the new ship
                self.spanShip()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    // MARK: - Computed Properties
    var getShip: SCNNode? {
        scene.rootNode.childNode(withName: "ship", recursively: true)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}
