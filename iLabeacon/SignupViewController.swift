//
//  SignupViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/20/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class SignupViewController: UIViewController {

	
	@IBOutlet weak var nameField: UITextField!
	
	@IBAction func submitButton(sender: AnyObject) {
		
		let name = nameField.text!
		
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
		NSNotificationCenter.defaultCenter().postNotificationName("NewUser", object: nil, userInfo: ["name": name])
		NSNotificationCenter.defaultCenter().postNotificationName("setLocalUser", object: nil)
		
		// Sets launch key to false
		let userDefaults = NSUserDefaults.standardUserDefaults()
		userDefaults.setBool(true, forKey: "hasLaunchedBefore")
		
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	// CoreData
	var managedObjectContext: NSManagedObjectContext? = nil
	
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
