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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
	
	override init() {
		super.init()
		FIRApp.configure()
		
		GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
		GIDSignIn.sharedInstance().delegate = self
	}
	
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		// If the user is not logged in, show the tutorial & signup pages. 
		// Otherwise, show the main screen.
		let userDeafults = NSUserDefaults.standardUserDefaults()
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		
		if (userDeafults.boolForKey("hasLaunchedBefore") == true) {
			let mainVC = storyboard.instantiateViewControllerWithIdentifier("MainUsersList")
			self.window?.rootViewController = mainVC
		} else {
			let tutorialVC = storyboard.instantiateViewControllerWithIdentifier("SignupView")
			self.window?.rootViewController = tutorialVC
		}
		
		self.window?.makeKeyAndVisible()
		
		// UINotifications
		application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
		
		// UIPageControl color configuration
		let pageControl = UIPageControl.appearance()
		pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
		pageControl.currentPageIndicatorTintColor = ThemeColors.tintColor
		pageControl.backgroundColor = UIColor.whiteColor()
		
        return true
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
				self.window?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
				
				return
			}
			
			// Saves user to Firebase Database (converted to User to save isIn, dateLastIn/Out properties
			let userAsUser = User(firebaseUser: user!)
			FIRDatabase.database().reference().child("users").child(user!.uid).setValue(userAsUser.toFirebase())
			
			// Sets launch key to false
			let userDefaults = NSUserDefaults.standardUserDefaults()
			userDefaults.setBool(true, forKey: "hasLaunchedBefore")
			
			// Instnatiates main view
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let mainVC = storyboard.instantiateViewControllerWithIdentifier("MainUsersList")
			self.window?.rootViewController!.presentViewController(mainVC, animated: true, completion: {
				NSNotificationCenter.defaultCenter().postNotificationName("UserDidSignupNotification", object: user)
			})
			
		})
		
	}
	
	func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
	            withError error: NSError!) {
		print("User \(user.description) disconnected.")
	}
	
    // MARK: - Notifications
    
    func showNotificationAlertingUser(withMessage message: String) {
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        notification.alertBody = message
        notification.alertAction = "Ok"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

}
