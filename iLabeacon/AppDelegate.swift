//
//  AppDelegate.swift
//  iLabeacon
//
//  Created by Peter Kos on 6/18/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import DATAStack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
	var dataStack: DATAStack? = nil
	var localUser: User? = nil
	let locationManager = CLLocationManager()
	
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		// Core Data
		dataStack = DATAStack(modelName: "iLabeaconModel")
		// NSNotification selector from Signup controller
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setAppDelegateLocalUser(_:)), name: "setLocalUser", object: nil)
		
		if (NSUserDefaults.standardUserDefaults().boolForKey("hasLaunchedBefore") == true) {
			NSNotificationCenter.defaultCenter().postNotificationName("setLocalUser", object: nil)
		}
		
		
        // Location
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
            // First region
            let mainiLabRegion = CLBeaconRegion(proximityUUID: pcUUID,
                                                major: iLabMajorMain,
                                                identifier: "iLab General Beacons")
            
            let entranceiLabRegion = CLBeaconRegion(proximityUUID: pcUUID,
                                                    major: iLabMajorEntrance,
                                                    identifier: "iLab Entrance Beacons")
        
//			locationManager.startMonitoringForRegion(mainiLabRegion)
//			locationManager.startRangingBeaconsInRegion(mainiLabRegion)
			locationManager.startMonitoringForRegion(entranceiLabRegion)
			locationManager.startRangingBeaconsInRegion(entranceiLabRegion)
		
			mainiLabRegion.notifyEntryStateOnDisplay = true
			entranceiLabRegion.notifyEntryStateOnDisplay = true
        
          locationManager.requestStateForRegion(mainiLabRegion)
          locationManager.requestStateForRegion(entranceiLabRegion)
		
		
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
		
		// Registers addBeacon NSNotification
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(addBeaconToUser(_:)), name: "addBeacon", object: nil)

		
        // Notifications
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
		
		
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

	func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
		
		guard localUser != nil else {
			print("localUser = nil")
			return
		}
		
		print("localUser name: \(localUser!.name!)")
		// TODO: Move CLBeaconRegion.identifier to instance variable to prevent typos
		if (region.identifier == "iLab Entrance Beacons") {

			switch state {
				case .Inside: localUser!.isIn = 1
				case .Outside: localUser!.isIn = 0
				case .Unknown: print("UNKNOWN ENTRANCE STATE")
			}
			
			do {
				try self.dataStack?.mainContext.save()
				NSNotificationCenter.defaultCenter().postNotificationName("refreshIsIn", object: nil)
				print("localUser updated state: \(localUser!.isIn!)")
				postUserStateToServer(localUser!)
			} catch {
				print("AppDelegate addBeaconToUser isIn update failed with error: \(error)")
				abort()
			}
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
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {

    }
	
	// MARK: - User with Location
	
	func setAppDelegateLocalUser(notification: NSNotification) {
		let fetchRequest = NSFetchRequest(entityName: "User")
		fetchRequest.predicate = NSPredicate(format: "isLocalUser == 1")
		
		// Fetches user
		do {
			localUser = (try self.dataStack!.mainContext.executeFetchRequest(fetchRequest) as! [User]).first
			print("AppDelegate local user name: \(localUser?.name)")
		} catch {
			// TODO: Add better error handling
			print("FETCH LOCALUSRE DIDN'T WORK IN APP DATA")
		}
	}
	
	func addBeaconToUser(notification: NSNotification) {

		print("NOTIFICATION: \((notification.object as! CLBeacon).description)")
		let beaconWithData = notification.object as! CLBeacon
		var existingBeacon: Beacon? = nil
		
		// If beacon doesn't exist, create it.
		// Otherwise, update the corresponding object with new data
		let fetchRequest = NSFetchRequest(entityName: "Beacon")
		fetchRequest.predicate = NSPredicate(format: "minor == %@", beaconWithData.minor)
		do {
			existingBeacon = ((try self.dataStack?.mainContext.executeFetchRequest(fetchRequest)) as! [Beacon]).first
		} catch {
			print("AppDelegate Notification addBeaconToUser fetchRequest error: \(error)")
			abort()
		}
		
		if let beacon = existingBeacon {
			
			// Copying all of those properties!
			beacon.accuracy  = beaconWithData.accuracy
			beacon.major     = beaconWithData.major
			beacon.minor     = beaconWithData.minor
			beacon.proximity = beaconWithData.proximity.rawValue
			beacon.rssi      = beaconWithData.rssi
//			beacon.user      = self.localUser!
			
		} else {
		
			let newBeacon = NSEntityDescription.insertNewObjectForEntityForName("Beacon", inManagedObjectContext: (self.dataStack?.mainContext)!) as! Beacon
			
			// Copying all of those properties!
			newBeacon.accuracy  = beaconWithData.accuracy
			newBeacon.major     = beaconWithData.major
			newBeacon.minor     = beaconWithData.minor
			newBeacon.proximity = beaconWithData.proximity.rawValue
			newBeacon.rssi      = beaconWithData.rssi
			newBeacon.user      = self.localUser!
			
			// Sets relationship <3
//			self.localUser!.beacon = newBeacon
			
			do {
				// Save beacon to CoreData
				try self.dataStack?.mainContext.save()
				
				print("NOTIFICATION: saved!")
				// Save beacon to network
//				networkManager.postNewUserToServer(newUser, completionHandler: { (error) in
//					print("NETWORK ERROR \(error!.description)")
//				})

			} catch {
				print(error)
				abort()
			}
			
		}
		
	}
	
	// MARK: - Networking
	func postUserStateToServer(user: User) {
		let networkManager = NetworkManager()
		// Save user to network
		networkManager.postUpdateToUserInfoToServer(user, completionHandler: { (error) in
			print("NETWORK ERROR \(error!.description)")
		})
	}

}

