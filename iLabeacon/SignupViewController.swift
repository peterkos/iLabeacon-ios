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
		
		// Changes status bar to match GIDSignIn view theme
		changeStatusBarTheme(toStyle: .Default)
		
		// Opens GIDSignIn view
		GIDSignIn.sharedInstance().signIn()
		
	}
	
	
	// MARK: - viewDidLoad and Variables
	
	let usersReference = FIRDatabase.database().reference().child("users")
	var newUser: User? = nil
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		changeStatusBarTheme(toStyle: .LightContent)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		GIDSignIn.sharedInstance().uiDelegate = self
	}
	
	
	// MARK: Other Functions
	
	func changeStatusBarTheme(toStyle style: UIStatusBarStyle) {
		// Changes status bar color to match normal app nav bar background
		// Delayed to allow GID sign in window to open
		let timeToDelay = 0.2
		let delay = timeToDelay * Double(NSEC_PER_SEC)  // nanoseconds per seconds
		let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
		
		dispatch_after(dispatchTime, dispatch_get_main_queue(), {
			UIApplication.sharedApplication().statusBarStyle = style
		})
	}
}
