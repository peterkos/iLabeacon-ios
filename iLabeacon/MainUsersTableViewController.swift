//
//  MainUsersTableViewController.swift
//  iLabeacon
//
//  Created by Peter Kos on 7/1/16.
//  Copyright © 2016 Peter Kos. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SVProgressHUD
import PermissionScope

class MainUsersTableViewController: UITableViewController, CLLocationManagerDelegate {

	// General properties
	let notificationCenter = NotificationCenter.default
	let errorHandler = ErrorHandler()
	let pscope = PermissionScope(backgroundTapCancels: false)
	
	// Firebase properties
	// FIXME: localUser nil!?
	var eventHandle: UInt? = nil
	let usersReference = FIRDatabase.database().reference().child("users")
	var localUser: User? {
		get {
			if let user = FIRAuth.auth()?.currentUser {
				return User(firebaseUser: user)
			} else {
				return nil
			}
		}
		
		set {
			self.localUser = newValue
		}
	}
	
	
	// Data
	var users = [User]()
	
	// Location!
	let locationManager = CLLocationManager()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Permissions
		pscope.addPermission(LocationAlwaysPermission(), message: "We need location to check if you're in the iLab or not.")
		
		// Configure UI to match theme
		pscope.closeButtonTextColor = ThemeColors.backgroundColor
		pscope.unauthorizedButtonColor = ThemeColors.backgroundColor
		pscope.closeButton = UIButton()
		
		// Show dialog with callbacks
		pscope.show({ finished, results in

			guard results.first != nil else {
				// TODO: Handle error properly
				print("This shouldn't happen.")
				return
			}
			
			// Setup location
			if (results.first?.type == .locationAlways) {
				
				self.locationManager.delegate = self
				let mainiLabRegion = CLBeaconRegion(proximityUUID: self.pcUUID, major: self.iLabMajorMain, identifier: "iLab General Beacons")
				
				self.locationManager.startMonitoring(for: mainiLabRegion)
				self.locationManager.startRangingBeacons(in: mainiLabRegion)
				self.locationManager.requestState(for: mainiLabRegion)
				mainiLabRegion.notifyEntryStateOnDisplay = true
			}
		
			}, cancelled: { (results) -> Void in
				print("thing was cancelled")
		})
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		SVProgressHUD.show()
		
		// Changes status bar color back to match theme
		UIApplication.shared.statusBarStyle = .lightContent
		
		// Firebase observer
		self.eventHandle = usersReference.observe(.value, with: { snapshot in
			
			// Check if local user exists
			guard self.localUser != nil else {
				self.errorHandler.localUserCouldNotBeCreatedException()
				return
			}
			
			var newListOfUsers = [User]()
			
			for user in snapshot.children.allObjects as! [FIRDataSnapshot] {
				newListOfUsers.append(User(snapshot: user))
			}
			
			// Sort by isIn, then dateLastIn
			let isInSortDescriptor = NSSortDescriptor(key: "isIn", ascending: false)
			let dateLastInSortDescriptor = NSSortDescriptor(key: "dateLastIn", ascending: false)
			newListOfUsers = (newListOfUsers as NSArray).sortedArray(using: [isInSortDescriptor, dateLastInSortDescriptor]) as! [User]
			
			// Puts localUser at top
			if let localUserIndex = newListOfUsers.index( where: { $0.name == self.localUser!.name } ) {
				newListOfUsers.insert(newListOfUsers.remove(at: localUserIndex), at: 0)
			} else {
				print("OUT OF SYNC. ABORT.")
			}
			
			self.users = newListOfUsers
			self.tableView.reloadData()
			SVProgressHUD.dismiss()
		})
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillAppear(animated)
		usersReference.removeObserver(withHandle: eventHandle!)
	}

	deinit {
		// Remove NSNotification observers
		notificationCenter.removeObserver(self)
	}
	
	// MARK: - Segues
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		// Loading selected user info in table view
		if let selectedUserVC = segue.destination as? SelectedUserTableViewController {
			print(tableView.indexPathForSelectedRow)
			selectedUserVC.user = users[(tableView.indexPathForSelectedRow! as NSIndexPath).row]
		}
	}
	
	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		// First section is just local user, second section is everypony else.
		if section == 0 {
			return 1
		} else {
			return users.count - 1
		}
		
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "You"
		} else {
			return "Users"
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Converts isIn to text 
		func isInText(_ isIn: Bool) -> String {
			return isIn ? "Is In" : "Is Not In"
		}
		
		// TODO: Subclass UITableViewCell, implement image
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		// localUser cell created separately
		if (indexPath as NSIndexPath).section == 0 {
			
			guard let user = localUser else {
				errorHandler.localUserCouldNotBeCreatedException()
				return cell
			}
			
			
			cell.textLabel!.text = user.name
			cell.detailTextLabel!.text = isInText(user.isIn)
			
			OperationQueue.main.addOperation({
				let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: (cell.frame.size.height)))
				view.backgroundColor = ThemeColors.tintColor
				cell.addSubview(view)
			})
			
			cell.textLabel?.textColor = UIColor.black
			
			return cell
			
		} else {

			let user = users[(indexPath as NSIndexPath).row]
			
			cell.textLabel!.text = user.name
			cell.detailTextLabel!.text = isInText(user.isIn)
			
			return cell
		}

	}

	
	// MARK: - Location
	
	// Location Properties
	let pcUUID = UUID(uuidString: "A495DEAD-C5B1-4B44-B512-1370F02D74DE")!
	
	let iLabMajorMain: CLBeaconMajorValue = 0x17AB
	let iLabMinor1: CLBeaconMinorValue = 0x1024
	let iLabMinor2: CLBeaconMinorValue = 0x1025
	let iLabMinor3: CLBeaconMinorValue = 0x1026
	let iLabMinor4: CLBeaconMinorValue = 0x1027
	
	
	// MARK: Location Management
	
	// Determines isIn status
	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		
		guard let localUser = localUser else {
			errorHandler.localUserCouldNotBeCreatedException()
			return
		}
		
		func isInState() {
			localUser.dateLastIn = Date(timeIntervalSinceNow: 0)
			localUser.isIn = true
		}
		
		func isNotInState() {
			localUser.dateLastOut = Date(timeIntervalSinceNow: 0)
			localUser.isIn = false
		}
		
		if (region.identifier == "iLab General Beacons") {
			switch state {
				case .inside: isInState(); print("isInState set!")
				case .outside: isNotInState(); print("isOutState set!")
				case .unknown: print("UNKNOWN ENTRANCE STATE")
			}
			
			print("Local user \(localUser.name) isIn: \(localUser.isIn)")
		}
		
		// Post notification and save to Firebase Database
		notificationCenter.post(name: Notification.Name(rawValue: "IsInDidUpdateNotification"), object: nil, userInfo: ["isIn": localUser.isIn.description])
		usersReference.child(localUser.uid!).setValue(localUser.toFirebase())
		print("================State: \(state.rawValue)============================")
	}
	
	func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		
		guard beacons.count > 0 else {
			return
		}
		
		var closestBeacon = beacons.first!

		for beacon in beacons {
			if (beacon.rssi < closestBeacon.rssi) {
				closestBeacon = beacon
			}
		}
		
		notificationCenter.post(name: Notification.Name(rawValue: "BeaconDidUpdateNotification"), object: closestBeacon, userInfo: ["isIn": localUser!.isIn])
	}

}
