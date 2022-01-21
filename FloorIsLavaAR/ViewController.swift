//
//  ViewController.swift
//  FloorIsLavaAR
//
//  Created by Dean Wahle on 1/20/22.
//

import UIKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        //configure session to detect horizontal surfaces
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
    }
    
    func createLava(planeAnchor: ARPlaneAnchor) -> SCNNode{
        let lavaNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        lavaNode.geometry?.firstMaterial?.diffuse.contents = UIImage.init(named: "lava")
        lavaNode.geometry?.firstMaterial?.isDoubleSided = true
        lavaNode.position = SCNVector3(planeAnchor.center.x,planeAnchor.center.y,planeAnchor.center.z)
        lavaNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        return lavaNode
    }
    
    //This delgate function checks if an AR anchor was added to the sceneView
    //an anchor is just information that encodes location, position, and size of something
    //in the real world, in this case it will be a plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let lavaNode = createLava(planeAnchor: planeAnchor)
        node.addChildNode(lavaNode)
        print("new flat service detected")
    }
    
    //this function will get called when anchors are updated (ex. floor keeps going)
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        print("updaing floor anchor")
        //when we see the floor is bigger, we remove the current lava
        node.enumerateChildNodes{(childNode, _) in
            childNode.removeFromParentNode()
        }
        //and make a new one based on the now larger floor anchor
        let lavaNode = createLava(planeAnchor: planeAnchor)
        node.addChildNode(lavaNode)
    }
    
    //this function is called when the device makes an error, and assigns 2 anchors to 1 surface
    //but fixes it
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        //this gets called when any anchors get removed, but we only want to do something when
        //plane anchors get removed
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        node.enumerateChildNodes{(childNode, _) in
            childNode.removeFromParentNode()
        }
    }
    
  
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
