//
//  SceneViewController.swift
//  swifty-protein
//
//  Created by Hendrik STANDER on 2018/11/08.
//  Copyright © 2018 Hendrik STANDER. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class SceneViewController: UIViewController {

    @IBOutlet weak var sceneView: SCNView!
    var gameView: SCNView!
    var gameScene: SCNScene!
    var cameraNode: SCNNode!
    var targetCreationTime : TimeInterval = 0
    var vectors : [[Substring]]?
    var connections : [[Substring]]?
    @IBOutlet weak var elementLbl: UILabel!
    
    @IBAction func shaerBtn(_ sender: Any) {
        let image = self.sceneView.snapshot()
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        present(vc, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        elementLbl.text = "Selected Element:"
        initView()
        initScene()
        initCamera()
        var i :Int = 0
        for vector in vectors!{
            createTarget(x: Float(vector[0])!, y: Float(vector[1])!, z: Float(vector[2])!, name: String(vector[3]))
            i += 1
        }
        for connection in connections!{
            let vector1 = vectors![Int(connection[0])! - 1]
            let vector2 = vectors![Int(connection[1])! - 1]
            
            let v1 = SCNVector3(x: Float(vector1[0])!, y: Float(vector1[1])!, z: Float(vector1[2])!)
            let v2 = SCNVector3(x: Float(vector2[0])!, y: Float(vector2[1])!, z: Float(vector2[2])!)
            let line = CylinderLine(parent: SCNNode(), v1: v1, v2: v2, radius: 0.1, color: UIColor.lightGray)
            gameScene.rootNode.addChildNode(line)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
    }
    
    func initView(){
        gameView = self.sceneView
        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
    }
    
    func initScene(){
        gameScene = SCNScene()
        gameView.scene = gameScene
        gameView.isPlaying = true
    }
    
    func initCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
        gameScene.rootNode.addChildNode(cameraNode)
        
    }
    
    func createTarget(x: Float, y: Float, z: Float, name: String){
        
        let geometry: SCNGeometry = SCNSphere(radius: 0.3)
        switch name {
        case "C":
            geometry.materials.first?.diffuse.contents = UIColor.black
            break
        case "H"	:
            geometry.materials.first?.diffuse.contents = UIColor.white
            break;
        case "N"    :
            geometry.materials.first?.diffuse.contents = UIColor.blue
            break;
        case "O"    :
            geometry.materials.first?.diffuse.contents = UIColor.red
            break;
        case "F", "CL" :
            geometry.materials.first?.diffuse.contents = UIColor.green
            break;
        case "BR" :
            geometry.materials.first?.diffuse.contents = UIColor(red: 0.6275, green: 0.051, blue: 0, alpha: 1) // DarkRed
            break;
        case "I", "LI", "NA", "K", "RB", "CS", "FR" :
            geometry.materials.first?.diffuse.contents = UIColor.purple
            break;
        case "HE", "NE", "AR", "XE", "KR" :
            geometry.materials.first?.diffuse.contents = UIColor.cyan
            break;
        case "P", "FE" :
            geometry.materials.first?.diffuse.contents = UIColor.orange
            break;
        case "S" :
            geometry.materials.first?.diffuse.contents = UIColor.yellow
            break;
        case "TI" :
            geometry.materials.first?.diffuse.contents = UIColor.gray
            break;
        case "B" :
            geometry.materials.first?.diffuse.contents = UIColor(red: 1, green: 0.8157, blue: 0.1333, alpha: 1) // peach
            break;
        case "BE", "MG", "CA", "SR", "BA", "RA" :
            geometry.materials.first?.diffuse.contents = UIColor(red: 0.1333, green: 0.5451, blue: 0.1333, alpha: 1) //forest green
            break;
        default:
            geometry.materials.first?.diffuse.contents = UIColor(red: 1, green: 0.7529, blue: 0.7961, alpha: 1) // pink
            break;
        }
        let geometryNode = SCNNode(geometry: geometry)
        
        geometryNode.position = SCNVector3(x: x, y: y, z: z)

        gameScene.rootNode.addChildNode(geometryNode)
        
        geometryNode.name = name

    }
    
    func handleTouch(node: SCNNode){
        if let n = node.name{
            elementLbl.text = "Selected Element: " + n
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        if let result = hitResults.first{
            handleTouch(node: result.node)
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepareing for unwind")
        let nodes = gameScene.rootNode.childNodes
        for node in nodes{
            node.removeFromParentNode();
        }
    }
}
