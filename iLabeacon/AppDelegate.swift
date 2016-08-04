//
//  AppDelegate.swift
//  iLabeacon
//
//  Created by Peter Kos on 6/18/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
	var localUser: User? = nil
	let locationManager = CLLocationManager()
	var networkManager: NetworkManager? = nil
	
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		// Firebase
		FIRApp.configure()
		
		// Network Manager instnatiated after CoreData initialization
		networkManager = NetworkManager()
		
		// If the user is not logged in, show the tutorial & signup pages. 
		// Otherwise, show the main screen.
		let userDeafults = NSUserDefaults.standardUserDefaults()
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		
		if (userDeafults.boolForKey("hasLaunchedBefore") == true) {
			let tutorialVC = storyboard.instantiateViewControllerWithIdentifier("MainNavVC")
			self.window?.rootViewController = tutorialVC
		} else {
			let mainVC = storyboard.instantiateViewControllerWithIdentifier("StartupTutorial")
			self.window?.rootViewController = mainVC
		}
		
		self.window?.makeKeyAndVisible()
		
		
		// Registers addBeacon NSNotification
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(addBeaconToUser(_:)), name: "addBeacon", object: nil)
		
		
		// UINotifications
		application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
		
		
        // Location
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
		
			// Regions
            let mainiLabRegion     = CLBeaconRegion(proximityUUID: pcUUID, major: iLabMajorMain, identifier: "iLab General Beacons")
            let entranceiLabRegion = CLBeaconRegion(proximityUUID: pcUUID, major: iLabMajorEntrance, identifier: "iLab Entrance Beacons")
        
//			locationManager.startMonitoringForRegion(mainiLabRegion)
//			locationManager.startRangingBeaconsInRegion(mainiLabRegion)
//			locationManager.startMonitoringForRegion(entranceiLabRegion)
//			locationManager.startRangingBeaconsInRegion(entranceiLabRegion)
		
			mainiLabRegion.notifyEntryStateOnDisplay = true
			entranceiLabRegion.notifyEntryStateOnDisplay = true
        
//          locationManager.requestStateForRegion(mainiLabRegion)
//          locationManager.requestStateForRegion(entranceiLabRegion)
		

		// UIPageControl color configuration
		let pageControl = UIPageControl.appearance()
		pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
		pageControl.currentPageIndicatorTintColor = ThemeColors.tintColor
		pageControl.backgroundColor = UIColor.whiteColor()
		
        return true
    }

    // MARK: - Location
    
    // Location Properties
    let pcUUID = NSUUID(UUIDString: "A495DEAD-C5B1-4B44-B512-1370F02D74DE")!
    
    let iLabMajorMain: CLBeaconMajorValue = 0x17AB
    let iLabMinor1: CLBeaconMinorValue = 0x1024
    let iLabMinor2: CLBeaconMinorValue = 0x1025
    let iLabMinor3: CLBeaconMinorValue = 0x1026
    let iLabMinor4: CLBeaconMinorValue = 0x1027
    
    let iLabMajorEntrance: CLBeaconMajorValue = 0x17AA
    let iLabMinor5: CLBeaconMinorValue = 0x1028
    let iLabMinor6: CLBeaconMinorValue = 0x1029

	
    // MARK: Location Management
	
	// Determines isIn status
	func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
		
		guard localUser != nil else {
			print("ERROR: localUser is nil")
			return
		}
		
		if (region.identifier == "iLab Entrance Beacons") {
			switch state {
				case .Inside: localUser!.isIn = 1
				case .Outside: localUser!.isIn = 0
				case .Unknown: print("UNKNOWN ENTRANCE STATE")
			}
			
			// Do something with the state!
		}
	}
	

	var count = 0
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        for beacon in beacons {
			NSNotificationCenter.defaultCenter().postNotificationName("addBeacon", object: beacon)
        }
		
        count += 1
    }
    
    // MARK: - Notifications
    
    func showNotificationAlertingUser(withMessage message: String) {
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        notification.alertBody = message
        notification.alertAction = "Ok"
        notification.userInfo = ["CustomField1": "w00t"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
	
	/*
	* BEACON MANAGMENT
	*
	* When the user connects to a beacon, a Beacon object will be created in CoreData, and that object will be
	* assigned to the local user. As the beacon data updates, it will be POSTed to the server at a predetermined
	* interval.
	*
	* There are two types of beacons: Entrance and General. Entrance beacons are meant to be triggered only two
	* times, while General beacons can be triggered an unlimited amount of times. These two will be used in
	* conjunction to determine when a user is "in".
	*
	* Data is managed like so: A user walks into a region. The beacons within that region send NSNotifications
	* to corresponding methods that will a) save the beacon to CoreData, if it hasn't already, and b) update said
	* data. Networking will also be handled here.
	*
	* Then, when a user attempts to view that data, the MainUsersTableViewController class just pulls what it needs
	* from CoreData automatically.
	*
	*/
	
	// MARK: - User with Location
	
	func setAppDelegateLocalUser(notification: NSNotification) {
		// Scan for isLocalUser, set localUser attribute on self
	}
	
	func addBeaconToUser(notification: NSNotification) {

		print("NOTIFICATION: \((notification.object as! CLBeacon).description)")
		let beaconWithData = notification.object as! CLBeacon
		var existingBeacon: Beacon? = nil
		
		// If beacon doesn't exist, create it.
		// Otherwise, update the corresponding object with new data
		
		if let beacon = existingBeacon {
			
		}
		
	}

}

