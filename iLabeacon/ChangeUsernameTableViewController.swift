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
		
		updateUsernameOnFirebase(withNewName: name)
		NSNotificationCenter.defaultCenter().postNotificationName("UsernameDidChangeNotification", object: name)
		navigationController?.popViewControllerAnimated(true)
	}
	
	func updateUsernameOnFirebase(withNewName name: String) {
		
		guard let user = FIRAuth.auth()?.currentUser else {
			print("ERROR: Username nil!")
			return
		}
		
		let usersReference = FIRDatabase.database().reference().child("users")
		usersReference.child(user.uid).child("name").setValue(name)
	}
}
