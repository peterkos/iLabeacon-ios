//
//  AppDelegate.swift
//  iLabeacon
//
//  Created by Peter Kos on 6/18/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import Firebase
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
			let tutorialVC = storyboard.instantiateViewControllerWithIdentifier("StartupTutorial")
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
		
		print("User \(user.description) has logged in!")
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
