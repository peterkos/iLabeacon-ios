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
	let userDeafults = NSUserDefaults.standardUserDefaults()
	let storyboard = UIStoryboard(name: "Main", bundle: nil)
	
	// Init Firebase & GIDSignIn
	override init() {
		super.init()
		FIRApp.configure()
		
		GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
		GIDSignIn.sharedInstance().delegate = self
	}
	
	// MARK: - Application functions
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		// If the user is not logged in, show the tutorial & signup pages. 
		// Otherwise, show the main screen.
		
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		
		if (userDeafults.boolForKey("hasLaunchedBefore") == true) {
			let mainVC = storyboard.instantiateViewControllerWithIdentifier("MainUsersList")
			self.window?.rootViewController = mainVC
		} else {
			let tutorialVC = storyboard.instantiateViewControllerWithIdentifier("SignupView")
			self.window?.rootViewController = tutorialVC
		}
		
		self.window?.makeKeyAndVisible()
		
		// UIPageControl color configuration
		let pageControl = UIPageControl.appearance()
		pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
		pageControl.currentPageIndicatorTintColor = ThemeColors.tintColor
		pageControl.backgroundColor = UIColor.whiteColor()
		
        return true
    }
	
	// MARK: - SignupViewControllerDelegate
	func deleteUserAccount() {
		
		// Reference for currentUser object
		let currentUser = FIRAuth.auth()?.currentUser!
		let googleUser = GIDSignIn.sharedInstance().currentUser
		
		FIRAuth.auth()?.currentUser?.deleteWithCompletion({ error in
			
			// Check if user signed in recently
			if (error != nil && error!.code == 17014) {
				SVProgressHUD.showInfoWithStatus("Please login again to verify your account.")
				SVProgressHUD.dismissWithDelay(2)
				
				// TODO: Show signin VC
				GIDSignIn.sharedInstance().signInSilently()
			}
			
			// Check for any other errors
			guard error == nil else {
				print("Signup error: \(error!)")
				SVProgressHUD.showErrorWithStatus("Something went wrong: \(error!.domain)")
				return
			}
			
			// Attempt to remove user database data
			guard currentUser != nil else {
				SVProgressHUD.showErrorWithStatus("Could not remove user data.")
				return
			}
			
			// (Actually) Remove user database data
			let usersReference = FIRDatabase.database().reference().child("users")
			usersReference.child(currentUser!.uid).removeValue()
			
			// Set hasLaunchedBefore preference
			self.userDeafults.setBool(false, forKey: "hasLaunchedBefore")
			
			// Instantiate signUpVC & remove MainUsersTableViewController
			let signUpVC = self.storyboard.instantiateViewControllerWithIdentifier("SignupView")
			self.window?.rootViewController?.navigationController?.popViewControllerAnimated(true)
			
			print("Successfully deleted user account.")
			self.window?.rootViewController = signUpVC
			SVProgressHUD.showSuccessWithStatus("Success!")
			SVProgressHUD.dismissWithDelay(1)

		})
	}
	
	// MARK: - Google SignIn URL
	@available(iOS 9.0, *)
	func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
		return GIDSignIn.sharedInstance().handleURL(url,
		                                            sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
		                                            annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
	}
	
	// Thanks iOS 8
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
		return GIDSignIn.sharedInstance().handleURL(url,
		                                            sourceApplication: sourceApplication,
		                                            annotation: annotation)
	}
	
	// MARK: Google SignIn
	func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
		if let error = error {
			print(error.localizedDescription)
			return
		}
		
		print("User email: \(signIn.hostedDomain) \(user.serverAuthCode)")
		let authentication = user.authentication
		let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
		
		FIRAuth.auth()!.signInWithCredential(credential, completion: { (user, error) in
			guard error == nil else {
				print(error!)
				return
			}
			
			// Loading indicator
			SVProgressHUD.popActivity()
			SVProgressHUD.show()
			SVProgressHUD.setDefaultStyle(.Custom)
			SVProgressHUD.setBackgroundColor(ThemeColors.backgroundColor)
			SVProgressHUD.setForegroundColor(UIColor.whiteColor())
			
			guard user!.email!.hasSuffix("@pinecrest.edu") else {
				
				// Signs user out and removes their account, as it is not a Pinecrest account.
				GIDSignIn.sharedInstance().signOut()
				user?.deleteWithCompletion({ error in
					guard error == nil else {
						print(error!)
						return
					}
				})
				
				let title = "Not a Pinecrest Account"
				let message = "Please sign in with your Pinecrest account: \"firstname.lastname@pinecrest.edu\"."
				let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
				
				let continueAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
				
				alertController.addAction(continueAction)
				
				// Dismisses loading indicator
				NSOperationQueue.mainQueue().addOperationWithBlock { SVProgressHUD.dismiss() }
				self.window?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
				
				return
			}
			
			// Saves user to Firebase Database (converted to User to save isIn, dateLastIn/Out properties
			let userAsUser = User(firebaseUser: user!)
			FIRDatabase.database().reference().child("users").child(user!.uid).setValue(userAsUser.toFirebase())
			
			// Sets launch key to false
			let userDefaults = NSUserDefaults.standardUserDefaults()
			userDefaults.setBool(true, forKey: "hasLaunchedBefore")
			
			
			// Checks if main view is already instantiated before continuing
			if (self.window?.rootViewController?.childViewControllers.first?.childViewControllers.first as? MainUsersTableViewController) != nil {
				print("Yay!")
				NSOperationQueue.mainQueue().addOperationWithBlock { SVProgressHUD.dismiss() }
				return
			} else {
				print(self.window?.rootViewController?.childViewControllers.description)
			}
			
			// Instnatiates main view
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let mainVC = storyboard.instantiateViewControllerWithIdentifier("MainUsersList")
			
			// Dismisses loading indicator
			NSOperationQueue.mainQueue().addOperationWithBlock { SVProgressHUD.dismiss() }
			
			// Shows main view
			self.window?.rootViewController?.presentViewController(mainVC, animated: true, completion: { 
				self.window?.rootViewController = mainVC
			})
			
		})
		
	}
	
	func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
	            withError error: NSError!) {
		print("User \(user.description) disconnected.")
	}

}
