//
//  ProteinViewController.swift
//  SwiftyProtein
//
//  Created by Сергей on 20.08.2021.
//

import UIKit
import SceneKit
import Photos

class ProteinViewController: UIViewController {
	
	var sceneView: SCNView!
	var scene: SCNScene!
	var camera: SCNCamera!
	var cameraNode: SCNNode!
	var cameraOrbit: SCNNode!
	var light: SCNLight!
	var lightNode: SCNNode!
	var atomView: AtomView!
	var highlightedSpshere: SCNGeometry?
	
	var pinchGestureRecognizer: UIPinchGestureRecognizer!
	var panGestureRecognizer: UIPanGestureRecognizer!
	var tapGestureRecognazer: UITapGestureRecognizer!
	var atoms: Atoms?
	
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
		self.view.backgroundColor = .white
		self.navigationController?.navigationBar.tintColor = (self.traitCollection.userInterfaceStyle == .dark) ? .white : .black
		
		atoms = getAtomsData()
		
		guard atoms != nil else {
			let alertVC = UIAlertController(title: NSLocalizedString("errorLoadingAtomStructures", comment: ""), message: "", preferredStyle: .alert)
			let action = UIAlertAction(title: "Ok", style: .cancel) { _ in
				
				self.navigationController?.popViewController(animated: false)
			}
			alertVC.addAction(action)
			self.present(alertVC, animated: true, completion: nil)
			return
		}
		
		pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(zoom))
		
		panGestureRecognizer = UIPanGestureRecognizer(target: self, action: 	#selector(handlePan))
		
		tapGestureRecognazer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		
		self.view.addGestureRecognizer(panGestureRecognizer)
		self.view.addGestureRecognizer(pinchGestureRecognizer)
		self.view.addGestureRecognizer(tapGestureRecognazer)
		
		let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareBarButtonAction))
		
		self.navigationItem.rightBarButtonItem = shareButton
		
		self.view.backgroundColor = .systemBackground
		activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
		activityIndicator.style = .large
		activityIndicator.tintColor = .systemTeal
		self.view.addSubview(activityIndicator)
		activityIndicator.isHidden = false
		activityIndicator.startAnimating()
	
		getDataFor(ligandCode: ligandCode) { [self] ligand in
			
			DispatchQueue.main.async {
				
				if ligand == nil {
					activityIndicator.stopAnimating()
					activityIndicator.isHidden = true
					showAllert()
				} else {
					self.ligand = ligand!
//					print(self.ligand!)
					self.createScene()
				}
			}
		}
    }
	
	//MARK: - Actions
	
	@objc func shareBarButtonAction(sender: UIBarButtonItem) {
		
		let photos = PHPhotoLibrary.authorizationStatus()
		
		if photos == .notDetermined {
			PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
				switch status {
				case .authorized:
					
					DispatchQueue.main.async {
						let image = self.sceneView.snapshot()
						
						let text = "Ligand name: \(self.ligand.baseInfo.name[0])\nType: \(self.ligand.baseInfo.type[0])\nFormila: \(self.ligand.baseInfo.formula[0])"
						
						let shareController = UIActivityViewController(activityItems: [image, text], applicationActivities: nil)
						self.present(shareController, animated: true, completion: nil)
					}
				case .denied:
					
					DispatchQueue.main.async {
						let alertController = UIAlertController(title: NSLocalizedString("accessPhotoTitle", comment: ""), message: NSLocalizedString("accessPhotoMessage", comment: ""), preferredStyle: .alert)
						let okAction = UIAlertAction(title: NSLocalizedString("settingsButton", comment: ""), style: .default) { _ in
							UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
						}
						let cancelAction = UIAlertAction(title: NSLocalizedString("cancelButton", comment: ""), style: .cancel, handler: nil)
						alertController.addAction(okAction)
						alertController.addAction(cancelAction)
						self.present(alertController, animated: true, completion: nil)
					}
				case .limited: print("limited")
				case .notDetermined: print("notDetermined")
				case .restricted: print("restricted")
				default: print("UNKNOWN")
				}
			}
		}
	}
	
	//MARK: - Handle Gesture Recognizer
	
	@objc func handlePan(sender: UIPanGestureRecognizer) {
		let transition = sender.velocity(in: sender.view!)
		cameraOrbit.eulerAngles.y -= Float(transition.x / CGFloat(panModifier)).radians
		cameraOrbit.eulerAngles.x -= Float(transition.y / CGFloat(panModifier)).radians
	}
	
	@objc func handleTap(sender: UITapGestureRecognizer) {
		
		let location = sender.location(in: sceneView)
		
		guard let result = sceneView.hitTest(location, options: nil).first else {
			removeSphereHilight()
			atomView.isHidden = true
			return
		}
		guard let geometry = result.node.geometry else { return }
		if geometry.isKind(of: SCNSphere.self) {
			
			removeSphereHilight()
			highlightedSpshere = geometry
			
			let material = SCNMaterial()
			material.emission.contents = UIColor.systemGreen
			
			highlightedSpshere?.materials.insert(material, at: 0)
			guard let index = atoms?.symbol.firstIndex(of: result.node.name!.capitalized) else { return }
			
			configureAtomView(forIndex: index)
			atomView.isHidden = false
		} else {
			removeSphereHilight()
			atomView.isHidden = true
		}
	}
	
	@objc func zoom(sender: UIPinchGestureRecognizer) {
		
		guard let camera = cameraOrbit.childNode(withName: "Camera", recursively: false) else { return }
		guard let light = cameraOrbit.childNode(withName: "Light", recursively: false) else { return }
		let scale = sender.velocity
		
		let z = camera.position.z - Float(scale) / Float(pinchModifier)
		if z < maxZoomOut, z > maxZoomIn {
			camera.position.z = z
			light.position.z = z
		}
	}
	
	//MARK: - Configure Scene
	
	private func createScene() {
		self.navigationItem.title = ligandCode
		
		sceneView = SCNView(frame: self.view.frame)

		atomView = AtomView()
		atomView.isHidden = true
		atomView.translatesAutoresizingMaskIntoConstraints = false
		
		sceneView.addSubview(atomView)
		
		atomView.leftAnchor.constraint(equalTo: sceneView.leftAnchor).isActive = true
		atomView.rightAnchor.constraint(equalTo: sceneView.rightAnchor).isActive = true
		atomView.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor).isActive = true
		atomView.heightAnchor.constraint(equalToConstant: 120).isActive = true
		
		self.view.addSubview(sceneView)
		
		scene = SCNScene()
		sceneView.scene = scene
		
		connectCameraAndLight()
		connectLigandModel()
		
		self.activityIndicator.stopAnimating()
		self.activityIndicator.isHidden = true
	}
	
	private func connectCameraAndLight() {
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
		lightNode.name = "Light"
		cameraOrbit.addChildNode(lightNode)
	
		scene.rootNode.addChildNode(cameraOrbit)
	}
	
	private func connectLigandModel() {
		
		var xCoords: [Double]
		var yCoords: [Double]
		var zCoords: [Double]
		
		if ligand.atomsInfo.xCoordinates.contains(nil) ||
			ligand.atomsInfo.yCoordinates.contains(nil) ||
			ligand.atomsInfo.zCoordinates.contains(nil) {
		
			if ligand.atomsInfo.xAltCoord.contains(nil) ||
				ligand.atomsInfo.yAltCoord.contains(nil) ||
				ligand.atomsInfo.zAltCoord.contains(nil) {
				showAllert()
				return
				
			} else {
				
				xCoords = ligand.atomsInfo.xAltCoord.map { $0!}
				yCoords = ligand.atomsInfo.yAltCoord.map { $0!}
				zCoords = ligand.atomsInfo.zAltCoord.map { $0!}
				
				let index = xCoords.count / 2
				cameraOrbit.position = SCNVector3Make(Float(xCoords[index]), Float(yCoords[index]), Float(zCoords[index]))
			}
		
		} else {
			xCoords = ligand.atomsInfo.xCoordinates.map { $0! }
			yCoords = ligand.atomsInfo.yCoordinates.map { $0! }
			zCoords = ligand.atomsInfo.zCoordinates.map { $0! }
			
			let xLimit = xCoords.first { $0 > 15.0 || $0 < -15.0 }
			let yLimit = yCoords.first { $0 > 15.0 || $0 < -15.0 }
			let zLimit = zCoords.first { $0 > 20.0 || $0 < -25.0 }
			if xLimit != nil || yLimit != nil || zLimit != nil {
				let index = xCoords.count / 2
				cameraOrbit.position = SCNVector3Make(Float(xCoords[index]), Float(yCoords[index]), Float(zCoords[index]))
			}
			
		}
		
		for i in 0..<ligand.atomsInfo.xCoordinates.count {
			
			let sphereGeometry = SCNSphere(radius: 0.3)
			let sphereNode = SCNNode(geometry: sphereGeometry)
			sphereNode.position = SCNVector3(x: Float(xCoords[i]), y: Float(yCoords[i]), z: Float(zCoords[i]))
			sphereNode.name = ligand.atomsInfo.symbol[i]
			
			let material = SCNMaterial()
			
			material.diffuse.contents = findCPKColor(symbol: ligand.atomsInfo.symbol[i])
			sphereGeometry.materials = [material]
			
		
			scene.rootNode.addChildNode(sphereNode)
		}
		
		guard let _ = ligand.bondInfo else { return }
		
		for (i, atom) in ligand.bondInfo!.atom_id_1.enumerated() {
			
			let indexFirst = ligand.atomsInfo.atomId.firstIndex(of: atom)!
			let atom2 = ligand.bondInfo!.atom_id_2[i]
			let indexSecond = ligand.atomsInfo.atomId.firstIndex(of: atom2)!
			
			var x = xCoords[indexFirst]
			var y = yCoords[indexFirst]
			var z = zCoords[indexFirst]
			
			var atomVector1 = SCNVector3(x, y, z)
			correctСoordinates(coordinate: &atomVector1)

			x = xCoords[indexSecond]
			y = yCoords[indexSecond]
			z = zCoords[indexSecond]
			
			var atomVector2 = SCNVector3(x, y, z)
			correctСoordinates(coordinate: &atomVector2)
			
			let cylinderNode = makeCylinder(from: atomVector1, to: atomVector2, radius: 0.1)
			
			scene.rootNode.addChildNode(cylinderNode)
					
			if ligand.bondInfo!.value_order[i] == "DOUB" {
				
				let cylinderNode2 = makeCylinder(from: atomVector1, to: atomVector2, radius: 0.045)
				
				scene.rootNode.addChildNode(cylinderNode2)
				
				var direction = atomVector1.cross(vector: atomVector2).normalized() / 10
		
				cylinderNode2.position = cylinderNode.position.addition(with: direction)
				
				direction = atomVector2.cross(vector: atomVector1).normalized() / 10
				cylinderNode.position =  cylinderNode.position.addition(with: direction)
				
				let geometry = cylinderNode.geometry as! SCNCylinder
				geometry.radius = 0.045
				
				scene.rootNode.addChildNode(cylinderNode2)
			}
		}
	}
	
	//MARK: - Private Functions
	
	private func correctСoordinates(coordinate: inout SCNVector3) {
		if coordinate.x == 0.0 {
			coordinate.x = 0.0001
		}
		if coordinate.y == 0.0 {
			coordinate.y = 0.0001
		}
		if coordinate.z == 0.0 {
			coordinate.z = 0.0001
		}
	}
	
	private func makeCylinder(from: SCNVector3, to: SCNVector3, radius: CGFloat) -> SCNNode {
		let lookAt = to - from
		let height = lookAt.length()
		let y = lookAt.normalized()
		var up = lookAt.cross(vector: to)
//		if up.x == 0 && up.y == 0.0 && up.z == 0.0 {
//			up.z = 1.0
//		}
		up = up.normalized()
		
		let x = y.cross(vector: up).normalized()
		let z = x.cross(vector: y).normalized()
		
		let transform = SCNMatrix4(x: x, y: y, z: z, w: from)
		
		let cylinderGeometry = SCNCylinder(radius: radius, height: CGFloat(height))
		
		let material = SCNMaterial()
		material.diffuse.contents = UIColor.systemGray
		cylinderGeometry.materials = [material]
		
		let cylinderNode = SCNNode(geometry: cylinderGeometry)
		cylinderNode.transform = SCNMatrix4MakeTranslation(0.0, height / 2, 0.0) * transform
		
		return cylinderNode
	}
	
	private func configureAtomView(forIndex index: Int) {
		
		atomView.view.backgroundColor = findColorForLiteral(literal: atoms!.series[index])
		
		if atoms!.ordinal[index] == -1 {
			
			atomView.atomicMassLabel.isHidden = true
			for label in atomView.levelsLabels {
				label.isHidden = true
			}
			atomView.nameLaLabel.text = atoms!.name_la[index]
			atomView.nameLanguageLabel.text = atoms!.valueForPropertyName(name: NSLocalizedString("name", comment: ""))[index]
			atomView.ordinalLabel.isHidden = true
			atomView.symbolLabel.text = atoms!.symbol[index]
			atomView.atomicWeightLabel.isHidden = true
			atomView.atomicNumberLabel.isHidden = true
			atomView.electronShellConfigLabel.isHidden = true
		} else {
			
			atomView.atomicMassLabel.text = String(atoms!.atomic_mass[index])
			
			let count = atoms!.levels[index].count
			for (number, label) in atomView.levelsLabels.enumerated() {
				if number < count {
					label.text = String(atoms!.levels[index][number])
				} else {
					label.text = ""
				}
			}
			atomView.nameLaLabel.text = atoms!.name_la[index]
			atomView.nameLanguageLabel.text = atoms!.valueForPropertyName(name: NSLocalizedString("name", comment: ""))[index]
			atomView.ordinalLabel.text = String(atoms!.ordinal[index])
			atomView.symbolLabel.text = atoms!.symbol[index]
			atomView.atomicWeightLabel.text = NSLocalizedString("weight", comment: "")
			atomView.atomicNumberLabel.text = NSLocalizedString("number", comment: "")
			atomView.electronShellConfigLabel.text  = NSLocalizedString("shell", comment: "")
		}
		
		
	}
	
	private func removeSphereHilight() {
		if let currentMaterial = highlightedSpshere?.materials {
			if currentMaterial.count > 1 {
				highlightedSpshere?.removeMaterial(at: 0)
			}
		}
	}
	
	private func getAtomsData() -> Atoms? {
		let url = Bundle.main.url(forResource: "atoms", withExtension: "json")!
		do {
			let data = try Data(contentsOf: url)
			let atomData = try JSONDecoder().decode(Atoms.self, from: data)
			return atomData
		} catch {
			print("\(error), \(error.localizedDescription)")
			return nil
		}
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
	
	private func findColorForLiteral(literal: String) -> UIColor {
		var color = UIColor.white
		switch literal {
		case "alkaliMetal":
			color = #colorLiteral(red: 0.9693536162, green: 0.6676997542, blue: 0.7528296113, alpha: 1)
		case "alkalineEarth":
			color = #colorLiteral(red: 0.998482883, green: 0.8616068959, blue: 0.6625244617, alpha: 1)
		case "transitionMetal":
			color = #colorLiteral(red: 0.9968060851, green: 0.9880352616, blue: 0.8624708056, alpha: 1)
		case "basicMetal":
			color = #colorLiteral(red: 0.8298531771, green: 0.9206516147, blue: 0.8480390906, alpha: 1)
		case "semimetal":
			color = #colorLiteral(red: 0.5784708858, green: 0.8501104712, blue: 0.9601013064, alpha: 1)
		case "nonmetal":
			color = #colorLiteral(red: 0.751444459, green: 0.8440964818, blue: 0.9399982095, alpha: 1)
		case "halogen":
			color = #colorLiteral(red: 0.8799833059, green: 0.878002584, blue: 0.9396790862, alpha: 1)
		case "nobleGas":
			color = #colorLiteral(red: 0.880866468, green: 0.8111004829, blue: 0.8989744782, alpha: 1)
		case "lanthanide":
			color = #colorLiteral(red: 0.9050008655, green: 0.8538355827, blue: 0.8319188952, alpha: 1)
		case "actinide":
			color = #colorLiteral(red: 0.9570552707, green: 0.8624190688, blue: 0.8301641345, alpha: 1)
		default:
			break
		}
		return color
	}
	
	private func showAllert() {
		let alertVC = UIAlertController(title: NSLocalizedString("errorTitleLigandDataNotFound", comment: ""), message: NSLocalizedString("errorMessageLigandDataNotFound", comment: ""), preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .cancel) { _ in
			
			self.navigationController?.popViewController(animated: false)
		}
		alertVC.addAction(action)
		self.present(alertVC, animated: true, completion: nil)
	}
}
