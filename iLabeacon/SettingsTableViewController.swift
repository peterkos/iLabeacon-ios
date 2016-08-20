//
//  LocalUserSettingsTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 8/8/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import SVProgressHUD

class SettingsTableViewController: UITableViewController {
	
	
	@IBOutlet weak var usernameCell: UITableViewCell!
	
	@IBOutlet weak var uuidCell: UITableViewCell!
	@IBOutlet weak var rssiCell: UITableViewCell!
	@IBOutlet weak var majorCell: UITableViewCell!
	@IBOutlet weak var minorCell: UITableViewCell!
	@IBOutlet weak var proximityCell: UITableViewCell!
	@IBOutlet weak var isInCell: UITableViewCell!
	
	
	@IBOutlet weak var deleteAccountCell: UITableViewCell!
	@IBAction func deleteAccountButtonPressed(sender: AnyObject) {
		
		let title = "Are you sure you want to delete your account?"
		let alertController = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
		
		let cancelAction = UIAlertAction(title: "Nevermind", style: .Cancel, handler: nil)
		
		let deleteAction = UIAlertAction(title: "Delete account", style: .Destructive) { alertAction in
			// TODO: Delete account
		}
		
		alertController.addAction(deleteAction)
		alertController.addAction(cancelAction)
		
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	
	let notificationCenter = NSNotificationCenter.defaultCenter()
	
	override func viewDidLoad() {
		
		// Allows UUID to fit in cell without clipping
		uuidCell.detailTextLabel!.adjustsFontSizeToFitWidth = true
		uuidCell.detailTextLabel!.numberOfLines = 1
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// Show username
		usernameCell.detailTextLabel!.text = FIRAuth.auth()?.currentUser?.displayName
		
		// Location notification updates
		notificationCenter.addObserver(self, selector: #selector(updateIsIn(_:)), name: "IsInDidUpdateNotification", object: nil)
		notificationCenter.addObserver(self, selector: #selector(updateBeacon(_:)), name: "BeaconDidUpdateNotification", object: nil)
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidAppear(animated)
		
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	
	// MARK: - Location data (updaed through NSNotificationCenter)
	func updateIsIn(notification: NSNotification) {
		isInCell.detailTextLabel!.text = notification.userInfo!["isIn"] as? String
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
