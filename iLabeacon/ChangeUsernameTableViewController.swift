//
//  ChangeUsernameTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 8/17/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SVProgressHUD

class ChangeUsernameTableViewController: UITableViewController, UITextFieldDelegate {

	@IBOutlet weak var usernameTextField: UITextField!
	
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		usernameTextField.resignFirstResponder()
		changeUsername()
		return true
	}
	
	@IBAction func doneButtonPressed(_ sender: AnyObject) {
		changeUsername()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		usernameTextField.delegate = self
		usernameTextField.text = FIRAuth.auth()?.currentUser?.displayName
	}
	
	
	// FUNctions for changing the user's username.
	func changeUsername() {
		let name = usernameTextField.text!
		
		guard name.characters.count <= 24 else {
			
			let alertController = UIAlertController(title: "Username Too Long",
			                                        message: "New username is too long, please try something shorter.",
			                                        preferredStyle: .alert)
			
			let continueAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
			
			alertController.addAction(continueAction)
			self.present(alertController, animated: true, completion: nil)
			
			return
		}
		
		// Loading indicator
		SVProgressHUD.show()
		
		// Update username on Firebase
		updateUsernameOnFirebase(withNewName: name) { error in
			
			OperationQueue.main.addOperation { SVProgressHUD.dismiss() }
			
			SVProgressHUD.showSuccess(withStatus: "Success!")
			SVProgressHUD.dismiss(withDelay: 0.6)
			_ = self.navigationController?.popViewController(animated: true)
		}
	}
	
	func updateUsernameOnFirebase(withNewName name: String, userDidUpdateCompletion: @escaping () -> ()) {
		
		guard let user = FIRAuth.auth()?.currentUser else {
			OperationQueue.main.addOperation {
				SVProgressHUD.showError(withStatus: "User nil!")
				SVProgressHUD.dismiss(withDelay: 2)
			}
			return
		}
		
		// First, update the "local" user profile
		let changeRequest = user.profileChangeRequest()
		changeRequest.displayName = name
		changeRequest.commitChanges { error in
			guard error == nil else {
				print(error!)
				return
			}
			
			// Then, update the databsae to match.
			let usersReference = FIRDatabase.database().reference().child("users")
			usersReference.child(user.uid).child("name").setValue(name)
			print("FIREBASE REMOTE: Username set.")
			
			userDidUpdateCompletion()
		}
		
		// Pass the username property back
		if let settingsVC = self.parent?.parent as? SettingsTableViewController {
			settingsVC.usernameCell.detailTextLabel!.text = name
		}
		
		
	}
}
