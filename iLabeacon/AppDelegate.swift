//
//  AppDelegate.swift
//  iLabeacon
//
//  Created by Peter Kos on 6/18/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    let locationManager = CLLocationManager()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startRangingBeaconsInRegion(CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "A495DEAD-C5B1-4B44-B512-1370F02D74DE")!, identifier: "Beacons"))
        return true
    }
    
    
    
    // MARK - Location Management
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        for beacon in beacons {
            print(beacon.description)
        }
        
        print("----------------")
    }



}

