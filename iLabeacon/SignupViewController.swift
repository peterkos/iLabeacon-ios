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
import SVProgressHUD

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
	
	
	// General properties
	let usersReference = FIRDatabase.database().reference().child("users")
	var currentUser: FIRUser? = nil
	var mainVC: UIViewController? = nil
	
	// MARK: View loading
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		changeStatusBarTheme(toStyle: .lightContent)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		GIDSignIn.sharedInstance().uiDelegate = self
		
		print("Bool: \(UserDefaults.standard.bool(forKey: "hasLaunchedBefore"))")
		if (UserDefaults.standard.bool(forKey: "hasLaunchedBefore") == true) {
			SVProgressHUD.show()
			SVProgressHUD.setDefaultStyle(.custom)
			SVProgressHUD.setBackgroundColor(ThemeColors.backgroundColor)
			SVProgressHUD.setForegroundColor(UIColor.white)
			print("Shown before")
			
			FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
				if let user = user {
					if self.currentUser != user {
						print("user is signed in!*******************************s")
						self.currentUser = user
						self.performSegue(withIdentifier: "LoginSegue", sender: self)
						SVProgressHUD.dismiss()
					}
				} else {
					SVProgressHUD.showError(withStatus: "User is nil.")
					SVProgressHUD.dismiss(withDelay: 2)
				}
			}
		} else {
			print("Hasn't launched before.")
		}
		
	}
	
	// MARK: Segue
	@IBAction func unwindToSignupViewController(segue: UIStoryboardSegue) {
		print("thething")
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "LoginSegue" {
			mainVC = segue.destination
		}
	}
	
	func removeMainVC(completion: @escaping () -> Void) {
		
		// FIXME: Return an actual Error
		guard let mainVC = mainVC else {
			print("ERROR: MainVC not instantiated.")
			return
		}
		
		mainVC.dismiss(animated: true) { 
			print("Dismissed mainVC from SignupVC!")
			completion()
		}
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

