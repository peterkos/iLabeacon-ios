//
//  SignupViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/20/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

	
	@IBOutlet weak var nameField: UITextField!
	
	@IBAction func submitButton(sender: AnyObject) {
		
		
		// Adds new user and posts notification to MainTBVC
		NSNotificationCenter.defaultCenter().postNotificationName("NewUser", object: nil, userInfo: ["name": nameField.text!])
		
		// Sets launch key to flase
		let userDefaults = NSUserDefaults.standardUserDefaults()
		userDefaults.setBool(true, forKey: "hasLaunchedBefore")

		
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
}
