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
	@IBAction func signIn(_ sender: AnyObject) {
		
		// Changes status bar to match GIDSignIn view theme
		changeStatusBarTheme(toStyle: .default)
		
		// Opens GIDSignIn view
		GIDSignIn.sharedInstance().signIn()
		
	}
	
	
	// MARK: - viewDidLoad and Variables
	
	let usersReference = FIRDatabase.database().reference().child("users")
	var newUser: User? = nil
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		changeStatusBarTheme(toStyle: .lightContent)
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
		let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
		
		DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
			UIApplication.shared.statusBarStyle = style
		})
	}
}
