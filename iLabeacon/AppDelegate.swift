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
        
        // First region
        let mainiLabRegion = CLBeaconRegion(proximityUUID: pcUUID,
                                            major: iLabMajor,
                                            identifier: "Main iLab Region")
        let secondiLabRegion = CLBeaconRegion(proximityUUID: pcUUID, identifier: "Second region")
        
        locationManager.startRangingBeaconsInRegion(mainiLabRegion)
        locationManager.startRangingBeaconsInRegion(secondiLabRegion)
        return true
    }
    
    
    // MARK: -- Location
    
    // Location Properties
    let pcUUID = NSUUID(UUIDString: "A495DEAD-C5B1-4B44-B512-1370F02D74DE")!
    let iLabMajor: CLBeaconMajorValue = 0x17AB
    let iLabMinor1: CLBeaconMinorValue = 0x1024
    let iLabMinor2: CLBeaconMinorValue = 0x1025
    let iLabMinor3: CLBeaconMinorValue = 0x1026
    let iLabMinor4: CLBeaconMinorValue = 0x1027
    
    // MARK - Location Management
    
    var count = 0
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        print(beacons.count)
        for beacon in beacons {
            print("\(beacon.description) \t \(count) \t \(region.identifier)")
        }
        
        count += 1
        print("--------------------")
    }



}

