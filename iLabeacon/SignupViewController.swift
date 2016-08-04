//
//  SignupViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/20/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit

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
	
	// Error checking functions
	func checkIfNameExists(name: String) -> Bool {
		
		// Fetch user, check if they exist. Easy enough, right?
		return false
	}
	
}
