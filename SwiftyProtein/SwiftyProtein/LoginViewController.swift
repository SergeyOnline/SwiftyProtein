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
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Please authorize the use of Face ID for data protection") { success, error in
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
		} else {
			let alertController = UIAlertController(title: NSLocalizedString("accessTitle", comment: ""), message: NSLocalizedString("accessMessage", comment: ""), preferredStyle: .alert)
			let okAction = UIAlertAction(title: NSLocalizedString("settingsButton", comment: ""), style: .default) { _ in
				UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
			}
			let cancelAction = UIAlertAction(title: NSLocalizedString("cancelButton", comment: ""), style: .cancel, handler: nil)
			alertController.addAction(okAction)
			alertController.addAction(cancelAction)
			self.present(alertController, animated: true, completion: nil)
		}
	}
}
