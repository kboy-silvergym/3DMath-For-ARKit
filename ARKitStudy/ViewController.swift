//
//  ViewController.swift
//  ARKitStudy
//
//  Created by Kei Fujikawa on 2018/08/25.
//  Copyright © 2018年 KBOY. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    @IBOutlet weak var zNearLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureForDouble(_:)))
        sceneView.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        guard let camera = sceneView.pointOfView?.camera else { return }
        let zNear = camera.zNear
        zNearLabel.text = "zNear:" + (round(zNear * 1000) / 1000).description
        
        slider.value = 0
        
        print("zNear: \(camera.zNear)")
        print("zFar: \(camera.zFar)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    @objc func tapGestureWrong(_ recognizer: UITapGestureRecognizer) {
        let finger = recognizer.location(in: nil)
        airPlane.position = SCNVector3(finger.x, finger.y, 0.3)
        sceneView.scene.rootNode.addChildNode(airPlane)
    }
    
    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        // カメラ座標系で30cm前
        let infrontOfCamera = SCNVector3(x: 0, y: 0, z: -0.3)
        
        // カメラ座標系 -> ワールド座標系
        guard let cameraNode = sceneView.pointOfView else { return }
        print(cameraNode.camera!.zNear)
        print(cameraNode.camera!.zFar)
        let pointInWorld = cameraNode.convertPosition(infrontOfCamera, to: nil)
        
        // ワールド座標系 -> スクリーン座標系
        var screenPos = sceneView.projectPoint(pointInWorld)
        
        // スクリーン座標系で
        // x, yだけ指の位置に変更
        // zは変えない
        let finger = recognizer.location(in: nil)
        screenPos.x = Float(finger.x)
        screenPos.y = Float(finger.y)
        
        // ワールド座標に戻す
        let finalPosition = sceneView.unprojectPoint(screenPos)
        
        // nodeを置く
        let airPlaneNode = airPlane
        airPlaneNode.position = finalPosition
        sceneView.scene.rootNode.addChildNode(airPlaneNode)
    }
    
    @objc func tapGesture2(_ recognizer: UITapGestureRecognizer) {
        // スクリーン座標系
        let finger = recognizer.location(in: nil)
        let pos = SCNVector3(finger.x, finger.y, 0.996)
        
        // ワールド座標に戻す
        let finalPosition = sceneView.unprojectPoint(pos)
        
        // nodeを置く
        let airPlaneNode = airPlane
        airPlaneNode.position = finalPosition
        sceneView.scene.rootNode.addChildNode(airPlaneNode)
    }
    
    @objc func tapGestureForDouble(_ recognizer: UITapGestureRecognizer) {
        // スクリーン座標系
        let finger = recognizer.location(in: nil)
        let pos = SCNVector3(finger.x, finger.y, 0.996)
        
        // ワールド座標に戻す
        let finalPosition = sceneView.unprojectPoint(pos)
        
        // nodeを置く
        let airPlaneNode = doubleAirPlanes
        airPlaneNode.position = finalPosition
        sceneView.scene.rootNode.addChildNode(airPlaneNode)
    }
    
    private let airPlane: SCNNode = {
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let node = scene.rootNode
        node.scale = SCNVector3(0.2, 0.2, 0.2)
        return node
    }()
    
    private let doubleAirPlanes: SCNNode = {
        let scene = SCNScene(named: "art.scnassets/double.scn")!
        let node = scene.rootNode
        
        // 拡大
        let ship1 = node.childNode(withName: "ship1", recursively: true)!
        ship1.scale = SCNVector3(0.4, 0.4, 0.4) // 今回は0.2がデフォ
        
        // 回転 using SCNVector4
        let ship2 = node.childNode(withName: "ship2", recursively: true)!
        ship2.eulerAngles.x = -.pi / 4
        
        ship2.rotation = SCNVector4(x: 1,
                                    y: 0,
                                    z: 0,
                                    w: -.pi / 4)
        
        
        
        
        
         ship2.rotation = SCNVector4(x: 0,
                                    y: 1,
                                    z: 0,
                                    w: -.pi / 4)
        // ship2.rotation = SCNVector4(x: 1, y: 0, z: 0, w: -.pi / 4)
        // ship2.orientation = SCNQuaternion(x: <#T##Float#>, y: <#T##Float#>, z: <#T##Float#>, w: <#T##Float#>)
        
        return node
    }()
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let value = sender.value
        
        if let camera = sceneView.pointOfView?.camera {
            guard value > 0 else {
                return
            }
            camera.zNear = Double(value * 1)
            
            let zNear = camera.zNear
            zNearLabel.text = "zNear:" + (round(zNear * 1000) / 1000).description
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let cameraNode = sceneView.pointOfView else { return }
        print(cameraNode.camera!.zNear)
    }
    
}
