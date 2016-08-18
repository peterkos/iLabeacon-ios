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
	
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		usernameTextField.resignFirstResponder()
		changeUsername()
		return true
	}
	
	@IBAction func doneButtonPressed(sender: AnyObject) {
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
		
		// Loading indicator
		SVProgressHUD.show()
		SVProgressHUD.setDefaultStyle(.Custom)
		SVProgressHUD.setBackgroundColor(ThemeColors.backgroundColor)
		SVProgressHUD.setForegroundColor(UIColor.whiteColor())
		
		updateUsernameOnFirebase(withNewName: name) { error in
			NSOperationQueue.mainQueue().addOperationWithBlock { SVProgressHUD.dismiss() }
			
			SVProgressHUD.showSuccessWithStatus("Success!")
			SVProgressHUD.dismissWithDelay(0.6)
			self.navigationController?.popViewControllerAnimated(true)
		}
		
	}
	
	func updateUsernameOnFirebase(withNewName name: String, userDidUpdateCompletion: () -> ()) {
		
		guard let user = FIRAuth.auth()?.currentUser else {
			print("ERROR: Username nil!")
			return
		}
		
		// First, update the "local" user profile
		let changeRequest = user.profileChangeRequest()
		changeRequest.displayName = name
		changeRequest.commitChangesWithCompletion { error in
			guard error == nil else {
				print(error!)
				return
			}
			
			print("FIREBASE LOCAL: username set")
			
			// Then, update the databsae to match.
			let usersReference = FIRDatabase.database().reference().child("users")
			usersReference.child(user.uid).child("name").setValue(name)
			print("FIREBASE: username set")
			
			userDidUpdateCompletion()
		}
		
		
	}
}
