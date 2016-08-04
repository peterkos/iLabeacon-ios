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
		
		// If name already exists, show an alert controller informing the user.
		guard checkIfNameExists(name) else {
			
			let alertController = UIAlertController(title: "Name Exists", message: "Name already exists. Please choose another.", preferredStyle: .Alert)
			
			let continueAction = UIAlertAction(title: "Ok", style: .Default, handler: { action in
				self.nameField.text! = ""
				print("User continued.")
			})
			
			alertController.addAction(continueAction)
			self.presentViewController(alertController, animated: true, completion: nil)
			
			return
		}
		
		// Adds new user and posts notification to MainTBVC
//		NSNotificationCenter.defaultCenter().postNotificationName("setLocalUser", object: nil)
		
		saveUser(name)
		
		// Sets launch key to false
		let userDefaults = NSUserDefaults.standardUserDefaults()
		userDefaults.setBool(true, forKey: "hasLaunchedBefore")
		
		// Instnatiates main view
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let mainVC = storyboard.instantiateViewControllerWithIdentifier("MainNavVC")
		self.presentViewController(mainVC, animated: true) {
			NSNotificationCenter.defaultCenter().postNotificationName("NewUser", object: nil, userInfo: ["name": name])
		}
		
	}
	
	
	// MARK: - viewDidLoad and Variables
	
	let usersReference = FIRDatabase.database().reference().child("users")
	
	override func viewDidLoad() {
		
	}
	
	// MARK: - Firebase FUNctions
	
	// Fetch user, check if they exist. Easy enough, right?
	func checkIfNameExists(name: String) -> Bool {
		
		var serverUserName = ""
		
		usersReference.child(name).observeSingleEventOfType(.Value, withBlock: { snapshot in
			serverUserName = snapshot.key
		}) { error in
			print("error")
		}
		
		print("Name \(name) exists: ")
		print("server name: \(serverUserName)")
		
		return (serverUserName != name) ? true : false
	}
	
	func saveUser(name: String) {
		usersReference.child(name).setValue(["name": name])
		
	}
	
}




























