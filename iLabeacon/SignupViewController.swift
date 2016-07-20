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
		
		// TODO: Add delegate callback
		self.dismissViewControllerAnimated(true, completion: nil)
		
		// Sets launch key to flase
		let userDefaults = NSUserDefaults.standardUserDefaults()
		userDefaults.setBool(true, forKey: "hasLaunchedBefore")
		
	}
	
}
