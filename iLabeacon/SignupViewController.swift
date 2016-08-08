//
//  SignupViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/20/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SignupViewController: UIViewController {
	
	// IB variables
	@IBOutlet weak var nameField: UITextField!
	
	// Submit button
	@IBAction func submitButton(sender: AnyObject) {
		
		let name = nameField.text!
		
		// If nothing was entered, show an alert.
		guard !nameField.text!.isEmpty else {
			createAlert(withTitle: "Invalid name", andMessage: "What are you, a spy? Please enter an actual name.")
			return
		}
		
		// If the username is too long to be shown without clipping, show an alert.
		guard nameField.text!.characters.count < 32 else {
			createAlert(withTitle: "Long Name", andMessage: "Your name is a bit too long to fit on the screen. Try abbreviating or using only your first or last name with an initial.")
			return
		}
		
		// If name already exists, show an alert controller informing the user.
		// Completion handler because it checks the server for the name.
		// If name doesn't exist, the app continues launching.
		checkIfNameExists(name, completion: { (exists) in
		
			guard exists else {
				self.createAlert(withTitle: "Name Already Exists", andMessage: "That name already exists. Try using your first/last name instead.")
				return
			}
			
			self.saveUser(name)
			
			// Sets launch key to false
			let userDefaults = NSUserDefaults.standardUserDefaults()
			userDefaults.setBool(true, forKey: "hasLaunchedBefore")
			
			// Instnatiates main view
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let mainVC = storyboard.instantiateViewControllerWithIdentifier("MainUsersList")
			self.presentViewController(mainVC, animated: true, completion: { 
				NSNotificationCenter.defaultCenter().postNotificationName("UserDidSignupNotification", object: self.newUser)
			})
		})
		
	}
	
	
	// MARK: - viewDidLoad and Variables
	
	let usersReference = FIRDatabase.database().reference().child("users")
	var newUser: User? = nil
	
	override func viewDidLoad() {
		
	}
	
	// MARK: - Alert creation function
	func createAlert(withTitle title: String, andMessage message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		
		let continueAction = UIAlertAction(title: "Ok", style: .Default, handler: { action in
			self.nameField.text! = ""
		})
		
		alertController.addAction(continueAction)
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	// MARK: - Firebase FUNctions
	
	// Fetch user, check if they exist. Easy enough, right?
	func checkIfNameExists(name: String, completion: (exists: Bool) -> Void) {
		
		var nameExists = false {
			didSet {
				completion(exists: nameExists)
			}
		}
		
		usersReference.observeSingleEventOfType(.Value, withBlock: { snapshot in
			if (snapshot.hasChild(name)) {
				print("false, duplicate")
				nameExists = false
			} else {
				print("true, unique")
				nameExists = true
			}
		}) { error in
			print("error")
		}
		
	}
	
	// Creates new user object and saves to Firebase
	func saveUser(name: String) {
		newUser = User(name: name)
		usersReference.child(name).setValue(newUser!.toFirebase())
	}
	
}

