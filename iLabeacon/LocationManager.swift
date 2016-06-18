//
//  LocationManager.swift
//  iLabeacon
//
//  Created by Peter Kos on 6/18/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//


import Foundation
import CoreLocation


class LocationManager: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    
    override init() {
        super.init()
    }
    
    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
}
