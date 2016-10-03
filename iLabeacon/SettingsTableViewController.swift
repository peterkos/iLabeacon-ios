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
	@IBAction func deleteAccountButtonPressed(_ sender: AnyObject) {
		
		let title = "Are you sure you want to delete your account?"
		let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
		
		let cancelAction = UIAlertAction(title: "Nevermind", style: .cancel, handler: nil)
		let deleteAction = UIAlertAction(title: "Delete account", style: .destructive) { alertAction in
			
			// Loading indicator
			SVProgressHUD.show()
			SVProgressHUD.setDefaultStyle(.custom)
			SVProgressHUD.setBackgroundColor(ThemeColors.backgroundColor)
			SVProgressHUD.setForegroundColor(UIColor.white)
			
			(UIApplication.shared.delegate as! AppDelegate).deleteUserAccount()
		}
		
		alertController.addAction(deleteAction)
		alertController.addAction(cancelAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	
	// General properties
	let notificationCenter = NotificationCenter.default
	
	override func viewDidLoad() {
		
		// Allows UUID to fit in cell without clipping
		uuidCell.detailTextLabel!.adjustsFontSizeToFitWidth = true
		uuidCell.detailTextLabel!.numberOfLines = 1
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Show username
		usernameCell.detailTextLabel!.text = FIRAuth.auth()?.currentUser?.displayName
		
		// Location notification updates
		notificationCenter.addObserver(self, selector: #selector(updateIsIn(_:)), name: NSNotification.Name(rawValue: "IsInDidUpdateNotification"), object: nil)
		notificationCenter.addObserver(self, selector: #selector(updateBeacon(_:)), name: NSNotification.Name(rawValue: "BeaconDidUpdateNotification"), object: nil)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		NotificationCenter.default.removeObserver(self)
	}

	
	// MARK: - Location data (updaed through NSNotificationCenter)
	func updateIsIn(_ notification: Notification) {
		isInCell.detailTextLabel!.text = (notification as NSNotification).userInfo!["isIn"] as? String
	}
	
	func updateBeacon(_ notification: Notification) {

		let beacon = notification.object as! CLBeacon
		
		uuidCell.detailTextLabel!.text = beacon.proximityUUID.uuidString ?? "Unknown"
		rssiCell.detailTextLabel!.text = beacon.rssi.description ?? "Unknown"
		majorCell.detailTextLabel!.text = beacon.major.description ?? "Unknown"
		minorCell.detailTextLabel!.text = beacon.minor.description ?? "Unknown"
		proximityCell.detailTextLabel!.text = beacon.proximity.rawValue.description ?? "Unknown"
		isInCell.detailTextLabel!.text = ((notification as NSNotification).userInfo!["isIn"] as? String)?.capitalized
		
	}

}
