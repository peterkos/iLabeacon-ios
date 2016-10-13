//
//  AppDelegate.swift
//  iLabeacon
//
//  Created by Peter Kos on 6/18/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

	
	// General properties
    var window: UIWindow?
	let userDeafults = UserDefaults.standard
	let storyboard = UIStoryboard(name: "Main", bundle: nil)
	let userRef = FIRDatabase.database().reference().child("users")
	let errorHandler = ErrorHandler()
	
	// Init Firebase & GIDSignIn
	override init() {
		super.init()
		FIRApp.configure()
		
		GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
		GIDSignIn.sharedInstance().delegate = self
	}
	
	
	// MARK: - Application functions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		// Loading indicator theme
		SVProgressHUD.setDefaultStyle(.custom)
		SVProgressHUD.setBackgroundColor(ThemeColors.backgroundColor)
		SVProgressHUD.setForegroundColor(UIColor.white)
		
		// Instantiate the signup view!
		self.window = UIWindow(frame: UIScreen.main.bounds)
		let signupVC = storyboard.instantiateViewController(withIdentifier: "SignupView")
		self.window?.rootViewController = signupVC

        return true
	}
	
	// MARK: - SignupViewControllerDelegate
	
	func logout() {
		
		do {
			try FIRAuth.auth()?.signOut()
		} catch {
			OperationQueue.main.addOperation {
				SVProgressHUD.showError(withStatus: error.localizedDescription)
				SVProgressHUD.dismiss(withDelay: 2)
			}
			
			return
		}
		
		// Dismiss main view
		let signupVC = self.window?.rootViewController as? SignupViewController
		if let signupVC = signupVC {
			signupVC.removeMainVC(completion: {
				print("Successfully logged out user account.")
				SVProgressHUD.showSuccess(withStatus: "Success!")
				SVProgressHUD.dismiss(withDelay: 1)
			})
		}
	}
	
	
	func logout(andDeleteUserAccount delete: Bool) {
		
		// Reference for currentUser object
		guard let currentUser = FIRAuth.auth()?.currentUser else {
			OperationQueue.main.addOperation {
				SVProgressHUD.showError(withStatus: "currentUser nil!")
				SVProgressHUD.dismiss(withDelay: 2)
			}
			
			return
		}
		
		FIRAuth.auth()?.currentUser?.delete(completion: { error in
			
			// Check if user signed in recently
			if (error != nil && (error as! NSError).code == 17014) {
				
				GIDSignIn.sharedInstance().signInSilently()
				
				// If GIDSignIn user == nil, stop
				guard GIDSignIn.sharedInstance().currentUser != nil else {
					OperationQueue.main.addOperation({ 
						SVProgressHUD.showError(withStatus: "Could not reauthenticate user.")
						SVProgressHUD.dismiss(withDelay: 4)
					})
					return
				}
				
				// Otherwise, grab the authentication credential
				let user = FIRAuth.auth()?.currentUser
				let auth = GIDSignIn.sharedInstance().currentUser.authentication
				let credential = FIRGoogleAuthProvider.credential(withIDToken: (auth?.idToken)!,
				                                                  accessToken: (auth?.accessToken)!)
				
				// Authenticate with the credential
				user?.reauthenticate(with: credential) { error in
					if let error = error {
						self.errorHandler.showError(error)
						return
					} else {
						print("YAY - User account reauthentication successful!")
					}
				}
			}
			
			// Check for any other errors
			if let error = error {
				self.errorHandler.showError(error)
				return
			}
			
			// Delete user account info from database
			if delete {
				let usersReference = FIRDatabase.database().reference().child("users")
				usersReference.child(currentUser.uid).removeValue()
			}
			
			// Set hasLaunchedBefore preference
			self.userDeafults.set(false, forKey: "hasLaunchedBefore")

			// Dismiss main view
			let signupVC = self.window?.rootViewController as? SignupViewController
			if let signupVC = signupVC {
				signupVC.removeMainVC(completion: {
					print("Successfully deleted user account.")
					SVProgressHUD.showSuccess(withStatus: "Success!")
					SVProgressHUD.dismiss(withDelay: 1)
				})
			}

		})
	}
	
	// MARK: - Google SignIn URL
	@available(iOS 9.0, *)
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
		return GIDSignIn.sharedInstance().handle(url,
		                                         sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
		                                         annotation: options[UIApplicationOpenURLOptionsKey.annotation])
	}
	
	// Thanks iOS 8
	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
	}
	
	// MARK: Google SignIn
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		
		if let error = error {
			errorHandler.showError(error)
			return
		}
		
		let authentication = user.authentication
		let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
		                                                  accessToken: (authentication?.accessToken)!)
		
		FIRAuth.auth()!.signIn(with: credential, completion: { (user, error) in
			
			if let error = error {
				self.errorHandler.showError(error)
				return
			}
			
			// Loading indicator
			SVProgressHUD.popActivity()
			SVProgressHUD.show()
			
			guard user!.email!.hasSuffix("@pinecrest.edu") else {
				
				// Signs user out and removes their account, as it is not a Pinecrest account.
				GIDSignIn.sharedInstance().signOut()
				
				user?.delete(completion: { error in
					if let error = error {
						self.errorHandler.showError(error)
						return
					}
				})
				
				let title = "Not a Pinecrest Account"
				let message = "Please sign in with your Pinecrest account: \"firstname.lastname@pinecrest.edu\"."
				let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
				
				let continueAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
				
				alertController.addAction(continueAction)
				
				// Dismisses loading indicator
				OperationQueue.main.addOperation { SVProgressHUD.dismiss() }
				self.window?.rootViewController!.present(alertController, animated: true, completion: nil)
				
				return
			}
			
			// If the user info already exists (i.e., logged out before), don't create another database entry.
			self.userRef.observeSingleEvent(of: .value, with: { snapshot in
				if !snapshot.exists() {
					print("== Doesn't exist, continuing!")
					let userAsUser = User(firebaseUser: user!)
					self.userRef.child(user!.uid).setValue(userAsUser.toFirebase())
				} else {
					print("== Exists arleady, continuing!")
				}
			})
			
			// Sets launch key to false
			let userDefaults = UserDefaults.standard
			userDefaults.set(true, forKey: "hasLaunchedBefore")
			
			// FIXME: May be irrelevant?
			// Checks if main view is already instantiated before continuing
			if (self.window?.rootViewController?.childViewControllers.first?.childViewControllers.first as? MainUsersTableViewController) != nil {
				OperationQueue.main.addOperation { SVProgressHUD.dismiss() }
				return
			}
			
			// Dismisses loading indicator
			OperationQueue.main.addOperation { SVProgressHUD.dismiss() }
			
			// Shows main view
			self.window?.rootViewController?.performSegue(withIdentifier: "LoginSegue", sender: nil)
		
		})
	}
}
