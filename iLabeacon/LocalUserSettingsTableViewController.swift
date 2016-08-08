//
//  LocalUserSettingsTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 8/8/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import CoreLocation

class LocalUserSettingsTableViewController: UITableViewController {
	
	
	@IBOutlet weak var usernameCell: UITableViewCell!
	
	@IBOutlet weak var uuidCell: UITableViewCell!
	@IBOutlet weak var rssiCell: UITableViewCell!
	@IBOutlet weak var majorCell: UITableViewCell!
	@IBOutlet weak var minorCell: UITableViewCell!
	@IBOutlet weak var proximityCell: UITableViewCell!
	@IBOutlet weak var isInCell: UITableViewCell!
	
	
	let userName = NSUserDefaults.standardUserDefaults().objectForKey("localUserName") as! String
	
	override func viewDidLoad() {
		
		// Allows UUID to fit in cell without clipping
		uuidCell.detailTextLabel!.adjustsFontSizeToFitWidth = true
		uuidCell.detailTextLabel!.numberOfLines = 1
		
		usernameCell.detailTextLabel!.text = userName
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateBeacon(_:)), name: "BeaconDidUpdateNotification", object: nil)
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidAppear(animated)
		
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func updateBeacon(notification: NSNotification) {

		let beacon = notification.object as! CLBeacon
		
		uuidCell.detailTextLabel!.text = beacon.proximityUUID.UUIDString ?? "Unknown"
		rssiCell.detailTextLabel!.text = beacon.rssi.description ?? "Unknown"
		majorCell.detailTextLabel!.text = beacon.major.description ?? "Unknown"
		minorCell.detailTextLabel!.text = beacon.minor.description ?? "Unknown"
		proximityCell.detailTextLabel!.text = beacon.proximity.rawValue.description ?? "Unknown"
		isInCell.detailTextLabel!.text = (notification.userInfo!["isIn"] as? String)?.capitalizedString
		
	}

}
