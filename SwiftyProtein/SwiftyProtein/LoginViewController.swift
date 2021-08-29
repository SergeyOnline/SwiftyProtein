//
//  LoginViewController.swift
//  SwiftyProtein
//
//  Created by Сергей on 19.08.2021.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {

	@IBOutlet weak var useBiometricsButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		useBiometrics(useBiometricsButton)
    }

	@IBAction func useBiometrics(_ sender: UIButton) {
		let context = LAContext()
		
		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Please authenticate to proceed.") { success, error in
				if success {
					DispatchQueue.main.async {
						//TODO: do something
						self.dismiss(animated: true, completion: nil)
					}
				} else {
					guard let error = error else { return }
					print(error.localizedDescription)
				}
			}
		}
	}
}
