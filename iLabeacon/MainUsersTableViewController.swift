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

class MainUsersTableViewController: UITableViewController, CLLocationManagerDelegate {

	// General properties
	let notificationCenter = NSNotificationCenter.defaultCenter()
	
	// Firebase properties
	let usersReference = FIRDatabase.database().reference().child("users")
	var localUser: User? {
		get {
			if let firUser = FIRAuth.auth()?.currentUser {
				return User(firebaseUser: firUser)
			} else {
				return nil
			}
		}
	}
	
	// Data
	var users = [User]()
	
	// Location!
	let locationManager = CLLocationManager()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Location
		locationManager.delegate = self
		locationManager.requestAlwaysAuthorization()
		
		// Regions
		let mainiLabRegion = CLBeaconRegion(proximityUUID: pcUUID, major: iLabMajorMain, identifier: "iLab General Beacons")
		
		locationManager.startMonitoringForRegion(mainiLabRegion)
		locationManager.startRangingBeaconsInRegion(mainiLabRegion)
		locationManager.requestStateForRegion(mainiLabRegion)
		mainiLabRegion.notifyEntryStateOnDisplay = true
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		usersReference.observeEventType(.Value, withBlock: { snapshot in
			
			var newListOfUsers = [User]()
			
			for user in snapshot.children.allObjects as! [FIRDataSnapshot] {
				newListOfUsers.append(User(snapshot: user))
			}
			
			// Sort by isIn, then dateLastIn
			let isInSortDescriptor = NSSortDescriptor(key: "isIn", ascending: false)
			let dateLastInSortDescriptor = NSSortDescriptor(key: "dateLastIn", ascending: false)
			newListOfUsers = (newListOfUsers as NSArray).sortedArrayUsingDescriptors([isInSortDescriptor, dateLastInSortDescriptor]) as! [User]
			
			// Puts localUser at top
			print("Local user sorting: \(self.localUser?.name)")
			print("Users from server: \(newListOfUsers.description)")
			if let localUserIndex = newListOfUsers.indexOf( { $0.name == self.localUser!.name } ) {
				newListOfUsers.insert(newListOfUsers.removeAtIndex(localUserIndex), atIndex: 0)
			} else {
				print("OUT OF SYNC. ABORT.")
			}
			
			self.users = newListOfUsers
			self.tableView.reloadData()
		})
	}
	
	deinit {
		// Remove observers
		notificationCenter.removeObserver(self)
	}

	
	// MARK: - Segues
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		// Loading selected user info in table view
		if let selectedUserVC = segue.destinationViewController as? SelectedUserTableViewController {
			selectedUserVC.user = users[tableView.indexPathForSelectedRow!.row]
		}
	}
	
	// MARK: - Table View

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		// First section is just local user, second section is everypony else.
		if section == 0 {
			return 1
		} else {
			return users.count - 1
		}
		
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "You"
		} else {
			return "Users"
		}
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		// Converts isIn to text 
		func isInText(isIn: Bool) -> String {
			return isIn ? "Is In" : "Is Not In"
		}
		
		// TODO: Subclass UITableViewCell, implement image
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		
		// localUser cell created separately
		if indexPath.section == 0 {
			
			let user = localUser!
			
			cell.textLabel!.text = user.name
			cell.detailTextLabel!.text = isInText(user.isIn)
			
			NSOperationQueue.mainQueue().addOperationWithBlock({
				let view = UIView(frame: CGRectMake(0, 0, 10, (cell.frame.size.height)))
				view.backgroundColor = ThemeColors.tintColor
				cell.addSubview(view)
			})
			
			cell.textLabel?.textColor = UIColor.blackColor()
			
			return cell
			
		} else {

			let user = users[indexPath.row]
			print("CellForRowAtIndexPath: \(user)")
			
			cell.textLabel!.text = user.name
			cell.detailTextLabel!.text = isInText(user.isIn)
			
			return cell
		}

	}

	
	// MARK: - Location
	
	// Location Properties
	let pcUUID = NSUUID(UUIDString: "A495DEAD-C5B1-4B44-B512-1370F02D74DE")!
	
	let iLabMajorMain: CLBeaconMajorValue = 0x17AB
	let iLabMinor1: CLBeaconMinorValue = 0x1024
	let iLabMinor2: CLBeaconMinorValue = 0x1025
	let iLabMinor3: CLBeaconMinorValue = 0x1026
	let iLabMinor4: CLBeaconMinorValue = 0x1027
	
	
	// MARK: Location Management
	
	// Determines isIn status
	func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
		
		func isInState() {
			localUser!.dateLastIn = NSDate.init(timeIntervalSinceNow: 0)
			localUser!.isIn = true
		}
		
		func isNotInState() {
			localUser!.dateLastOut = NSDate.init(timeIntervalSinceNow: 0)
			localUser!.isIn = false
		}
		
		if (region.identifier == "iLab General Beacons") {
			switch state {
			case .Inside: isInState()
			case .Outside: isNotInState()
			case .Unknown: print("UNKNOWN ENTRANCE STATE")
			}
			
			print("Local user \(localUser!.name) isIn: \(localUser!.isIn)")
		}
		
		// Post notification and save to Firebase Database
		notificationCenter.postNotificationName("IsInDidUpdateNotification", object: nil, userInfo: ["isIn": localUser!.isIn.description])
		usersReference.child(localUser!.uid!).setValue(localUser!.toFirebase())
	}
	
	func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
		
		guard beacons.count > 0 else {
			return
		}
		
		var closestBeacon = beacons.first!

		for beacon in beacons {
			if (beacon.rssi < closestBeacon.rssi) {
				closestBeacon = beacon
			}
		}
		
		notificationCenter.postNotificationName("BeaconDidUpdateNotification", object: closestBeacon, userInfo: ["isIn": localUser!.isIn])
	}

}
