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
import GoogleSignIn


protocol SignupViewControllerDelegate {
	func deleteUserAccount()
}


class SignupViewController: UIViewController, GIDSignInUIDelegate {
	
	// IB variables
	@IBAction func signIn(sender: AnyObject) {
		GIDSignIn.sharedInstance().signIn()
		
		// Changes status bar color to match SafariViewController popup background
		UIApplication.sharedApplication().statusBarStyle = .Default
	}
	
	// MARK: - viewDidLoad and Variables
	
	let usersReference = FIRDatabase.database().reference().child("users")
	var newUser: User? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()

		GIDSignIn.sharedInstance().uiDelegate = self
	}
	
}
