//
//  AppDelegate.swift
//  iLabeacon
//
//  Created by Peter Kos on 6/18/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
	
	override init() {
		super.init()
		FIRApp.configure()
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
	
    // MARK: - Notifications
    
    func showNotificationAlertingUser(withMessage message: String) {
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        notification.alertBody = message
        notification.alertAction = "Ok"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

}
