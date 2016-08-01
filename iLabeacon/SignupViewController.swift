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
			print("name exists!")
			return
		}
		
		// Adds new user and posts notification to MainTBVC
		NSNotificationCenter.defaultCenter().postNotificationName("NewUser", object: nil, userInfo: ["name": name])
		
		// Sets launch key to flase
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
