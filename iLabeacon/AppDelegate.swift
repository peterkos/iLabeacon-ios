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
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, SignupViewControllerDelegate {


	// General properties
    var window: UIWindow?
	let userDeafults = UserDefaults.standard
	let storyboard = UIStoryboard(name: "Main", bundle: nil)
	
	// Init Firebase & GIDSignIn
	override init() {
		super.init()
		FIRApp.configure()
		
		GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
		GIDSignIn.sharedInstance().delegate = self
	}
	
	// MARK: - Application functions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		// If the user is not logged in, show the tutorial & signup pages. 
		// Otherwise, show the main screen.
		
		self.window = UIWindow(frame: UIScreen.main.bounds)
		
		if (userDeafults.bool(forKey: "hasLaunchedBefore") == true) {
			let mainVC = storyboard.instantiateViewController(withIdentifier: "MainUsersList")
			self.window?.rootViewController = mainVC
		} else {
			let tutorialVC = storyboard.instantiateViewController(withIdentifier: "SignupView")
			self.window?.rootViewController = tutorialVC
		}
		
		self.window?.makeKeyAndVisible()
		
		// UIPageControl color configuration
		let pageControl = UIPageControl.appearance()
		pageControl.pageIndicatorTintColor = UIColor.lightGray
		pageControl.currentPageIndicatorTintColor = ThemeColors.tintColor
		pageControl.backgroundColor = UIColor.white
		
        return true
    }
	
	// MARK: - SignupViewControllerDelegate
	func deleteUserAccount() {
		
		// Reference for currentUser object
		let currentUser = FIRAuth.auth()?.currentUser!
		
		FIRAuth.auth()?.currentUser?.delete(completion: { error in
			
			// Check if user signed in recently
			if (error != nil && (error as! NSError).code == 17014) {
				SVProgressHUD.showInfo(withStatus: "Please login again to verify your account.")
				SVProgressHUD.dismiss(withDelay: 2)
				
				// TODO: Show signin VC
				GIDSignIn.sharedInstance().signInSilently()
			}
			
			// Check for any other errors
			guard error == nil else {
				print("Signup error: \(error!)")
				SVProgressHUD.showError(withStatus: "Something went wrong: \((error as! NSError).domain)")
				return
			}
			
			// Attempt to remove user database data
			guard currentUser != nil else {
				SVProgressHUD.showError(withStatus: "Could not remove user data.")
				return
			}
			
			// (Actually) Remove user database data
			let usersReference = FIRDatabase.database().reference().child("users")
			usersReference.child(currentUser!.uid).removeValue()
			
			// Set hasLaunchedBefore preference
			self.userDeafults.set(false, forKey: "hasLaunchedBefore")
			
			// Instantiate signUpVC & remove MainUsersTableViewController
			let signUpVC = self.storyboard.instantiateViewController(withIdentifier: "SignupView")
			_ = self.window?.rootViewController?.navigationController?.popViewController(animated: true)
			
			print("Successfully deleted user account.")
			self.window?.rootViewController = signUpVC
			SVProgressHUD.showSuccess(withStatus: "Success!")
			SVProgressHUD.dismiss(withDelay: 1)

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
		return GIDSignIn.sharedInstance().handle(url,
		                                            sourceApplication: sourceApplication,
		                                            annotation: annotation)
	}
	
	// MARK: Google SignIn
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		if let error = error {
			print(error.localizedDescription)
			return
		}
		
		print("User email: \(signIn.hostedDomain) \(user.serverAuthCode)")
		let authentication = user.authentication
		let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
		
		FIRAuth.auth()!.signIn(with: credential, completion: { (user, error) in
			guard error == nil else {
				print(error!)
				return
			}
			
			// Loading indicator
			SVProgressHUD.popActivity()
			SVProgressHUD.show()
			SVProgressHUD.setDefaultStyle(.custom)
			SVProgressHUD.setBackgroundColor(ThemeColors.backgroundColor)
			SVProgressHUD.setForegroundColor(UIColor.white)
			
			guard user!.email!.hasSuffix("@pinecrest.edu") else {
				
				// Signs user out and removes their account, as it is not a Pinecrest account.
				GIDSignIn.sharedInstance().signOut()
				user?.delete(completion: { error in
					guard error == nil else {
						print(error!)
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
			
			// Saves user to Firebase Database (converted to User to save isIn, dateLastIn/Out properties
			let userAsUser = User(firebaseUser: user!)
			FIRDatabase.database().reference().child("users").child(user!.uid).setValue(userAsUser.toFirebase())
			
			// Sets launch key to false
			let userDefaults = UserDefaults.standard
			userDefaults.set(true, forKey: "hasLaunchedBefore")
			
			
			// Checks if main view is already instantiated before continuing
			if (self.window?.rootViewController?.childViewControllers.first?.childViewControllers.first as? MainUsersTableViewController) != nil {
				print("Yay!")
				OperationQueue.main.addOperation { SVProgressHUD.dismiss() }
				return
			} else {
				print(self.window?.rootViewController?.childViewControllers.description)
			}
			
			// Instnatiates main view
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let mainVC = storyboard.instantiateViewController(withIdentifier: "MainUsersList")
			
			// Dismisses loading indicator
			OperationQueue.main.addOperation { SVProgressHUD.dismiss() }
			
			// Shows main view
			self.window?.rootViewController?.present(mainVC, animated: true, completion: { 
				self.window?.rootViewController = mainVC
			})
			
		})
		
	}
	
	func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!, withError error: Error!) {
		print("User \(user.description) disconnected.")
	}

}
