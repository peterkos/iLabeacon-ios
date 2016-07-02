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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
	var dataStack: CoreDataStack? = nil
	var hasLaunchedBefore = false
	let locationManager = CLLocationManager()
	
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		
		// Checks for first launch.
		if (!hasLaunchedBefore) {
			// Do something
		}
		
		// Core Data
		dataStack = CoreDataStack()
		
		
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
        
            locationManager.startMonitoringForRegion(mainiLabRegion)
            locationManager.startMonitoringForRegion(entranceiLabRegion)
//            locationManager.startRangingBeaconsInRegion(mainiLabRegion)
//            locationManager.startRangingBeaconsInRegion(entranceiLabRegion)
        
            mainiLabRegion.notifyEntryStateOnDisplay = true
            entranceiLabRegion.notifyEntryStateOnDisplay = true
        
            locationManager.requestStateForRegion(mainiLabRegion)
            locationManager.requestStateForRegion(entranceiLabRegion)
        
        // Notifications
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        return true
    }
	
	func applicationWillTerminate(application: UIApplication) {
		
		dataStack?.saveContext()
	}
    
    
    // MARK: -- Location
    
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
    
    // MARK - Location Management
    
    var count = 0
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print(region.identifier)
        showNotificationAlertingUser(withMessage: "Entered \(region.identifier)")
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print(region.identifier)
        showNotificationAlertingUser(withMessage: "Left \(region.identifier)")
    }
    
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        for beacon in beacons {
            print("\(beacon.description) \t \(count) \t \(region.identifier)")
        }
        
        count += 1
//        print("--------------------")
    }
    
    // MARK: Notifications
    
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


}

