//
//  ProteinViewController.swift
//  SwiftyProtein
//
//  Created by Сергей on 20.08.2021.
//

import UIKit
import SceneKit

struct LigandData: Decodable {
	let baseInfo: ChemComp
	let atomsInfo: ChemCompAtom
	let bondInfo: ChemCompBond
	
	private enum CodingKeys: String, CodingKey {
		case baseInfo = "chem_comp"
		case atomsInfo = "chem_comp_atom"
		case bondInfo = "chem_comp_bond"
	}
}

struct ChemCompBond: Decodable {
	let atom_id_1: [String]
	let atom_id_2: [String]
	let value_order: [String]
}

struct ChemCompAtom: Decodable {
	var xCoordinates: [Double]
	var yCoordinates: [Double]
	var zCoordinates: [Double]
	var atomId: [String]
	var symbol: [String]
	
	private enum CodingKeys: String, CodingKey {
		case xCoordinates = "pdbx_model_Cartn_x_ideal"
		case yCoordinates = "pdbx_model_Cartn_y_ideal"
		case zCoordinates = "pdbx_model_Cartn_z_ideal"
		case atomId = "atom_id"
		case symbol = "type_symbol"
	}
}

struct ChemComp: Decodable {
	let id: [String]
	let name: [String]
	let type: [String]
	let formula: [String]
}

class ProteinViewController: UIViewController {
	
	var sceneView: SCNView!
	var scene: SCNScene!
	var camera: SCNCamera!
	var cameraNode: SCNNode!
	var cameraOrbit: SCNNode!
	var light: SCNLight!
	var lightNode: SCNNode!
	var atomLabel: UILabel!
	var pinchGestureRecognizer: UIPinchGestureRecognizer!
	var panGestureRecognizer: UIPanGestureRecognizer!
	var tapGestureRecognazer: UITapGestureRecognizer!
	
	var ligandCode: String
	var ligand: LigandData!
	var activityIndicator: UIActivityIndicatorView!
	
	let panModifier = 100
	let pinchModifier = 5
	let maxZoomOut: Float = 100.0
	let maxZoomIn: Float = 10.0

	
	init(ligandCode: String) {
		self.ligandCode = ligandCode
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareBarButtonAction))
		
		self.navigationItem.rightBarButtonItem = shareButton
		
		pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(zoom))
		
		panGestureRecognizer = UIPanGestureRecognizer(target: self, action: 	#selector(handlePan))
		
		tapGestureRecognazer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		
		view.addGestureRecognizer(panGestureRecognizer)
		view.addGestureRecognizer(pinchGestureRecognizer)
		view.addGestureRecognizer(tapGestureRecognazer)

		self.view.backgroundColor = .systemBackground
		activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
		activityIndicator.style = .large
		activityIndicator.tintColor = .systemTeal
		self.view.addSubview(activityIndicator)
		activityIndicator.isHidden = false
		activityIndicator.startAnimating()
	
		getDataFor(ligandCode: ligandCode) { ligand in
			self.ligand = ligand
			print(self.ligand!)
			DispatchQueue.main.async {
				self.createScene()
			}
		}
		
        // Do any additional setup after loading the view.
    }
	
	@objc func shareBarButtonAction(sender: UIBarButtonItem) {
		
		let image = sceneView.snapshot()
		let shareController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
		self.present(shareController, animated: true, completion: nil)
	}
	
	@objc func handlePan(sender: UIPanGestureRecognizer) {
		let transition = sender.velocity(in: sender.view!)
		cameraOrbit.eulerAngles.y -= Float(transition.x / CGFloat(panModifier)).radians
		cameraOrbit.eulerAngles.x -= Float(transition.y / CGFloat(panModifier)).radians
	}
	
	@objc func handleTap(sender: UITapGestureRecognizer) {
		
		let location = sender.location(in: sceneView)
		print(location)
		
		guard let result = sceneView.hitTest(location, options: nil).first else {
			atomLabel.isHidden = true
			return
		}
		guard let geometry = result.node.geometry else { return }
		if geometry.isKind(of: SCNSphere.self) {
			atomLabel.text = result.node.name!.capitalized
			atomLabel.isHidden = false
		} else {
			atomLabel.isHidden = true
		}
	}
	
	@objc func zoom(sender: UIPinchGestureRecognizer) {
		
		guard let camera = cameraOrbit.childNode(withName: "Camera", recursively: false) else { return }
		let scale = sender.velocity
		
		let z = camera.position.z - Float(scale) / Float(pinchModifier)
		if z < maxZoomOut, z > maxZoomIn {
			camera.position.z = z
		}
	}
	
	
	func createScene() {
		
		self.navigationItem.title = ligand.baseInfo.formula[0]
		
		sceneView = SCNView(frame: self.view.frame)
		
		atomLabel = UILabel()
		atomLabel.backgroundColor = .systemBackground
		atomLabel.font = UIFont(name: atomLabel.font.fontName, size: 30)
		atomLabel.textAlignment = .center
		atomLabel.translatesAutoresizingMaskIntoConstraints = false
		
		sceneView.addSubview(atomLabel)
		
		atomLabel.leftAnchor.constraint(equalTo: sceneView.leftAnchor).isActive = true
		atomLabel.rightAnchor.constraint(equalTo: sceneView.rightAnchor).isActive = true
		atomLabel.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor).isActive = true
		atomLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
		
		
		self.view.addSubview(sceneView)
		
		scene = SCNScene()
		sceneView.scene = scene
		
		camera = SCNCamera()
		cameraNode = SCNNode()
		cameraNode.camera = camera
		cameraNode.position = SCNVector3(0.0, 0.0, 25.0)
		cameraNode.name = "Camera"
		
		cameraOrbit = SCNNode()
		cameraOrbit.addChildNode(cameraNode)
		
		light = SCNLight()
		light.type = .omni
		lightNode = SCNNode()
		lightNode.light = light
		lightNode.position = SCNVector3(0, 0, 25.0)
		cameraOrbit.addChildNode(lightNode)
	
		scene.rootNode.addChildNode(cameraOrbit)
		
		let xCoord = ligand.atomsInfo.xCoordinates
		let yCoord = ligand.atomsInfo.yCoordinates
		let zCoord = ligand.atomsInfo.zCoordinates
		
		for i in 0..<ligand.atomsInfo.xCoordinates.count {
			
			let sphereGeometry = SCNSphere(radius: 0.3)
			let sphereNode = SCNNode(geometry: sphereGeometry)
			sphereNode.position = SCNVector3(x: Float(xCoord[i]), y: Float(yCoord[i]), z: Float(zCoord[i]))
			sphereNode.name = ligand.atomsInfo.symbol[i]
			
			let material = SCNMaterial()
			material.diffuse.contents = findCPKColor(symbol: ligand.atomsInfo.symbol[i])
			sphereGeometry.materials = [material]
			
			scene.rootNode.addChildNode(sphereNode)
		}
		
		for (i, atom) in ligand.bondInfo.atom_id_1.enumerated() {
			
			print("ATOM: \(atom)")
			print(ligand.atomsInfo.atomId)
			
			let indexFirst = ligand.atomsInfo.atomId.firstIndex(of: atom)!
			let atom2 = ligand.bondInfo.atom_id_2[i]
			let indexSecond = ligand.atomsInfo.atomId.firstIndex(of: atom2)!
			
			var x = ligand.atomsInfo.xCoordinates[indexFirst]
			var y = ligand.atomsInfo.yCoordinates[indexFirst]
			var z = ligand.atomsInfo.zCoordinates[indexFirst]
			
			let atomVector1 = SCNVector3(x, y, z)
			
			x = ligand.atomsInfo.xCoordinates[indexSecond]
			y = ligand.atomsInfo.yCoordinates[indexSecond]
			z = ligand.atomsInfo.zCoordinates[indexSecond]
			
			let atomVector2 = SCNVector3(x, y, z)
			
			let params = сalculateCylinderParams(atom1: atomVector1, atom2: atomVector2)
			
			
			let cylinderGeometry = SCNCylinder(radius: 0.1, height: CGFloat(params.length))
			let cylinderNode = SCNNode(geometry: cylinderGeometry)
			cylinderNode.position = params.position
			cylinderNode.eulerAngles = params.orientation
			
			let material = SCNMaterial()
			material.diffuse.contents = UIColor.systemGray
			
			cylinderGeometry.materials = [material]
			
			scene.rootNode.addChildNode(cylinderNode)
			
			if ligand.bondInfo.value_order[i] == "DOUB" {
				let cylinderGeometry2 = SCNCylinder(radius: 0.045, height: CGFloat(params.length))
				let cylinderNode2 = SCNNode(geometry: cylinderGeometry2)
				cylinderNode2.position = params.position
				cylinderNode2.eulerAngles = params.orientation
				
				
//				cylinderNode.position.multScalar(scalar: 0.045)
//				cylinderNode2.position.multScalar(scalar: -0.045)
				cylinderNode.position.multScalar(scalar: 0.97)
				cylinderNode2.position.multScalar(scalar: 1.03)
				
//				if cylinderNode.position.x < cylinderNode2.position.x + 0.01 &&
//					cylinderNode.position.x > cylinderNode2.position.x - 0.01 {
//					cylinderNode2.position.y += 0.09
//					cylinderNode.position.y -= 0.09
//				} else {
//					cylinderNode2.position.x += 0.09
//					cylinderNode.position.x -= 0.09
//				}
				
				cylinderGeometry.radius = 0.045
				cylinderGeometry2.materials = [material]
				
				scene.rootNode.addChildNode(cylinderNode2)
			}
			
			
		}
		
		self.activityIndicator.stopAnimating()
		self.activityIndicator.isHidden = true
	}
	
	private func сalculateCylinderParams(atom1: SCNVector3, atom2: SCNVector3) -> (position: SCNVector3, length: Float, orientation: SCNVector3) {
		let x = (atom1.x + atom2.x) / 2
		let y = (atom1.y + atom2.y) / 2
		let z = (atom1.z + atom2.z) / 2
		let position = SCNVector3(x, y, z)
		let length = sqrt(pow(atom2.x - atom1.x, 2) + pow(atom2.y - atom1.y, 2) + pow(atom2.z - atom1.z, 2))
		
		var orientation = SCNVector3(atom2.x - atom1.x, atom2.y - atom1.y, atom2.z - atom1.z)
		
		let lxz = pow((pow(Double(orientation.x), 2) + pow(Double(orientation.z), 2)), 0.5)
		var pitch, pitchB: Double
		if orientation.y < 0 {
			pitchB = .pi - asin(Double(lxz)/Double(length))
			} else {
				pitchB = asin(Double(lxz)/Double(length))
			}
			if orientation.z == 0 {
				pitch = pitchB
			} else {
				pitch = sign(Double(orientation.z)) * pitchB
			}
			var yaw: Double
			if orientation.x == 0 && orientation.z == 0 {
				yaw = 0
			} else {
				let inner = Double(orientation.x) / (Double(length) * sin (pitch))
				if inner > 1 {
					yaw = .pi / 2
				} else if inner < -1 {
					yaw = .pi / 2
				} else {
					yaw = asin(inner)
				}
			}
		orientation.x = Float(pitch)
		orientation.y = Float(yaw)
		orientation.z = 0
		return (position, length, orientation)
	}
	
	func posBetween(first: SCNVector3, second: SCNVector3) -> SCNVector3 {
			return SCNVector3Make((first.x + second.x) / 2, (first.y + second.y) / 2, (first.z + second.z) / 2)
	}
	
	private func findCPKColor(symbol: String) -> UIColor {
		
		var color = #colorLiteral(red: 0.8661281466, green: 0.4679610729, blue: 0.999409616, alpha: 1)
		
		switch symbol {
		case "H":
			color = #colorLiteral(red: 0.9318111539, green: 0.9319418073, blue: 0.9317700267, alpha: 1)
		case "C":
			color = #colorLiteral(red: 0.1335564554, green: 0.1335814297, blue: 0.1335485578, alpha: 1)
		case "N":
			color = #colorLiteral(red: 0.1313079, green: 0.1992628574, blue: 0.9991223216, alpha: 1)
		case "O":
			color = #colorLiteral(red: 0.9991984963, green: 0.2052571177, blue: 0, alpha: 1)
		case "F", "CL":
			color = #colorLiteral(red: 0.01234949101, green: 0.9764581323, blue: 0.05207475275, alpha: 1)
		case "BR":
			color = #colorLiteral(red: 0.5987756252, green: 0.1320302188, blue: 0.001294235932, alpha: 1)
		case "I":
			color = #colorLiteral(red: 0.4010791779, green: 0.121291019, blue: 0.7329799533, alpha: 1)
		case "HE", "NE", "AR", "XE", "KR":
			color = #colorLiteral(red: 0.0046923724, green: 0.9846308827, blue: 1, alpha: 1)
		case "P":
			color = #colorLiteral(red: 1, green: 0.6004234552, blue: 0, alpha: 1)
		case "S":
			color = #colorLiteral(red: 0.9983043075, green: 0.8975249529, blue: 0.1387948394, alpha: 1)
		case "B":
			color = #colorLiteral(red: 1, green: 0.6682869196, blue: 0.4682716131, alpha: 1)
		case "LI", "NA", "K", "RB", "CS":
			color = #colorLiteral(red: 0.4650434256, green: 0.1696062386, blue: 0.9978974462, alpha: 1)
		case "BE", "MG", "CA", "SR", "BA", "RA":
			color = #colorLiteral(red: 0.0008495936636, green: 0.4677394032, blue: 0, alpha: 1)
		case "TI":
			color = #colorLiteral(red: 0.598842442, green: 0.598928988, blue: 0.5988151431, alpha: 1)
		case "FE":
			color = #colorLiteral(red: 0.8668220639, green: 0.4676414728, blue: 0, alpha: 1)
		default:
			break
		}
		return color
	}
}

extension Float {
	var radians: Float {
		return self * .pi / 180
	}
	
	var degrees: Float {
		return self  * 180 / .pi
	}
}

extension SCNVector3 {
	mutating func multScalar(scalar: Float) {
//		self.x += scalar
//		self.y += scalar
//		self.z += scalar
		self.x *= scalar
		self.y *= scalar
		self.z *= scalar
	}
}
