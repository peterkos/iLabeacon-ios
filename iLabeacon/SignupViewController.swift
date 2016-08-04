//
//  SignupViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/20/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import CoreData
import DATAStack
import SwiftyJSON

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
	
	// Custom Ivars
	var dataStack: DATAStack? = nil
	var managedObjectContext: NSManagedObjectContext? = nil

	
	override func viewDidLoad() {
		dataStack = (UIApplication.sharedApplication().delegate as! AppDelegate).dataStack
		managedObjectContext = dataStack?.mainContext
		
		// Downloads users to be indexed
		let networkManager = NetworkManager()
		networkManager.updateListOfUsersFromNetwork()
	}
	
	// Error checking functions
	func checkIfNameExists(name: String) -> Bool {
		
		var userWithSameName: User?
		
		let fetchRequest = NSFetchRequest(entityName: "User")
		fetchRequest.predicate = NSPredicate(format: "name == %@", name)
		
		// Fetches user
		do {
			userWithSameName = (try managedObjectContext?.executeFetchRequest(fetchRequest) as! [User]).first
		} catch {
			// TODO: Add better error handling
			print("FETCH USERWITHSAMENAME DIDN'T WORK")
		}
		
		// Checks if name exists, returns appropriatley
		if (userWithSameName != nil) {
			return false
		} else {
			return true
		}
		
	}
	
}
